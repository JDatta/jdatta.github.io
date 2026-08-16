---
layout: post
title: Debugging a permgen leak in Java
---

Out of memory errors in java can some time mean a memory leak in application. One class of those memory errors are related to memory pressure in permgen. This is typically identified by exception message like `Root Cause Exception: java.lang.OutOfMemoryError: PermGen space`

As memory management is done by jvm, identifying and debugging memory leaks in java can be tricky. 
In case of permgen leaks, more so. Reasons for this include:

 - Permgen leaks are rare
 - More often than not; out of memory errors due to permgen space is not a leak but a legitimate case of memory crunch. In which case you either need to allocate more memory to permgen using `-XX:MaxPermSize` jvm parameter or strip down your libraries and dependencies.
 - permgen is not included in standard jvm heap dump generated using `jmap -dump:file=file.hprof <pid>` or with option `-XX:+HeapDumpOnOutOfMemoryError`. They are also typically not included in profiler outputs. You often need to take inferences indirectly.

## What is a permgen leak

Permgen stands for permanent generation. It is the part of the jvm memory map which is used by java to store classes (_i.e._ codes; executable instructions), interned strings etc. Conceptually this is similar to the code area of a _"C"_ process. 

The default permgen size in jvm is rather small, the max permgen size is only 64 MB for 32bit jvm, 83.2 MB for 64bit jvm <sup>[[see here]](http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html#PerformanceTuning)</sup>. When this space get full, you see exceptions like: `Root Cause Exception: java.lang.OutOfMemoryError: PermGen space`. If your dependency library size is more than this size, then you have a genuine issue and not a leak and you should increase the permgen size using jvm parameters ` -XX:PermSize` and `-XX:MaxPermSize`. For example, this could be the java command to start your application: `java -cp lib/* MyClass -XX:PermSize=128m -XX:MaxPermSize=256m`

This permgen area is also garbage collected by jvm. Problems arise when there are items in the permgen area, which are no longer in use but somehow there are still references to them. In which case this is a case of leak.

## Case Study
Stale references to permgen objects are more complicated than references in java heap space. Consider the following case.

Suppose you are using a custom classloader (See: [URLClassLoader](https://docs.oracle.com/javase/7/docs/api/java/net/URLClassLoader.html)) then all the classes loaded by this classloader would occupy a fresh area in the permgen space. You can create a plethora of java objects using this loader. As long as we hold a reference to even one of these objects the loader won't be garbage collected. And till the loader is garbage collected all the classes loaded by it would occupy space in permgen area. For example, the culprit object could be a daemon thread started by one of your own code or some code in the dependency libraries that you call. Another example would be a Runnable object registered in application hooks like the JVMShutDownHook. Other cases include static variables and thread local variables.

This is confusing because the space occupied by the culprit java object in heap could be small, say in few bytes. The space occupied by the loader object in the heap would also be typically small, again within a few bytes. So the heap dump analysis won't tell you anything suspicious. But the classes loaded by the loader still occupying permgen area could easily be in mega bytes. In general, if you see multiple custom loader instances alive in heap dump is a red flag and require more investigation.


## Debugging steps

### Generate and analyze permgen dump
Before analyzing heap dump, for permgen issues you should try to get the permgen dump. If the process for which you are getting permgen error is still live, run this command to extract the permgen dump and save it to a file
``` bash
jmap -permstat <pid> > /tmp/permgen_dump
```

This is a simple file with the following format:
``` bash
$ head /tmp/permgen_dump
class_loader    classes bytes   parent_loader   alive?  type

<bootstrap>     1989    11034488          null          live    <internal>
0x0000000691e83e40      1       3056    0x000000069000cda8      dead    sun/reflect/DelegatingClassLoader@0x000000068004f888
0x0000000691f93938      0       0       0x000000069000cda8      live    com/company/CustomClassLoader@0x00000006839f3198
0x00000006905393e8      1       3056    0x000000069000cda8      dead    sun/reflect/DelegatingClassLoader@0x000000068004f888
0x0000000691a42bb0      1       3040      null          dead    sun/reflect/DelegatingClassLoader@0x000000068004f888
[...]
```

First we would sum the bytes occupied by all alive loaders.
``` bash
$ grep live /tmp/permgen_dump|tail -n +3 |awk '{s+=$3} END{print s}'
283469897
```
This must be more than the permgen size limit.

From this file we would prepare a __histogram__ to find out loaders occupying most of the spaces. Following steps show how I created the histogram from above file. Skip ahead if you want as the scripts are pretty basic.

``` bash
## Print the type information (last column i.e. col 6)
## and bytes column and save to a file
$ cat /tmp/permgen_dump|tail -n +3 |awk '{print $6" "$3}' > /tmp/hist1.txt

## Invoke a simple python script to print the histogram largest to smallest
$ .hist.py /tmp/hist1.txt
225629976       com/company/CustomClassLoader@0x00000006839f3198
57763728        sun/misc/Launcher$AppClassLoader@0x000000068020c380
11034488        <internal>
859720  org/apache/derby/impl/services/reflect/ReflectLoaderJava2@0x0000000681cf52f8
719832  sun/reflect/DelegatingClassLoader@0x000000068004f888
75904   sun/misc/Launcher$ExtClassLoader@0x00000006801a0998
289     N/A
0       org/apache/hadoop/hbase/util/DynamicClassLoader@0x000000068bb4b768
0       java/util/ResourceBundle$RBClassLoader@0x0000000680562600
[...]
```

The python script is pretty straight forward. It just sums the bytes against same type and prints the result in descending order. The script is added in appendix as reference.

Now, from the above histogram, we can clearly see unusually large amount of permgen space is occupied by a single loader: `com/company/CustomClassLoader@0x00000006839f3198`

At this step, you can check your code to see how this custom class loader is being used and find out obvious errors like object references kept in static variables in some of _your_ classes etc. If not found you need to analyze heap dump.

### How to generate heap dump
You can generate heap dump using following command
``` bash
jmap -dump:file=/tmp/dump.hprof <pid>
```
Alternatively you can add the following java options in your startup command to automatically create heap dump whenever there is an `OutOfMemoryError`
```
-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/path/to/dump/dir
```


Once you have the dump file, you should use a memory analyzer tool to analyze. One such tool is [eclipse MAT Memory Analyzer](http://www.eclipse.org/mat/). This comes both as a plugin of eclipse and a stand alone program. 

### Analyze the heap dump in Eclipse MAT
Open the hprof file generated above in eclipse. Once it is loaded, click on `Dominator Tree` option under the head `Action Items` in `Overview` page. 

In the dominator tree page look for the loader class name which we noted to take unusually large amount of permgen space in permgen dump. For our case this is `com/company/CustomClassLoader`. Right click on any one of the instances of CustomClassLoader in the dominator tree and click `Path to GC Roots > exclude weak references`. This would give you a list of instances that is holding the reference of the loader and preventing it from getting garbage collected. Expand each of them individually and check the corresponding code. For example, when we checked the code we found one daemon thread was being started by one of our dependency API preventing the loader to be garbage collected.


### Analyze the heap dump using `jhat`
`jhat` is another heap dump analyzing tool

Run the command to start `jhat` server
``` bash
$ jhat -port 9091 /tmp/dump.hprof
```

Now open [http://localhost:9091](http://localhost:9091) on any browser. Scroll down to the end of the page and click [`Show heap histogram`](http://localhost:9091/histo/). In the page that opens, search for the suspicious class we found in permgen histogram (`CustomClassLoader` for our case). Follow the hyper link and come to the page describing class `com.company.CustomClassLoader`. At the end of the page there would be a section with name `Other Queries`. Under this section there is a hyper link `Reference Chains from Rootset > Exclude weak refs`. Click on it. In the page that opens, there would be comprehensive list of codes that is holding the loader reference and preventing it from getting garbage collected. This page corresponds to the `Path to GC Root` page of `eclipse MAT`.

Remember, the loader would not be garbage collected until all the classes/objects loaded by it directly or transitively are not garbage collected. From the path to GC root page you need to carefully analyze the list of object references which was directly or indirectly loaded by our custom loader and not garbage collected.

## Appendix:
### Python code to generate histogram
``` python
#!/usr/bin/python
import sys
import operator

# The histogram file path should be given in argument
# The file should have two columns, key and value 
# Each line in the histogram file should contain the key
# then a space and then the value
# The following code would sum the values against the same 
# key and print the result in descending order

f = open(sys.argv[1]) # Open the histogram file 

# Create histogram map
hist = {}
for line in f:
    line = line.strip()
    if line == "":
        continue
    fields = line.split()
    mtype = fields[0].strip()
    mval = fields[1].strip()

    if mtype in hist:
        hist[mtype] = hist[mtype] + int(mval)
    else:
        hist[mtype] = int(mval)

# Sort in descending order
sorted_hist = reversed(sorted(hist.items(), key=operator.itemgetter(1)))

# print
for i in sorted_hist:
    print i[1], "\t", i[0]

```

---------------
Mirrored from: <https://gist.github.com/JDatta/7f82db25ccef7772a0e73fe9ceb329d7>, <http://techgargle.blogspot.com/2016/11/java-debugging-permgen-leak.html>
