---
layout: post
title: In this post, let's add a step-by-step guide for setting up Facebook's Llama2 on a MacBook in CPU mode
date: 2024-01-14
---

In this post, let's add a step-by-step guide for setting up Facebook's Llama2 on a MacBook in CPU mode. Aimed at engineers and tech enthusiasts, this walkthrough covers everything from the initial download to creating your own AI chatbot, akin to ChatGPT.

[Llama2](https://ai.meta.com/llama/) is a popular open-source model from Facebook. In this article let's go over how one can run Llama2 on a MacBook in CPU mode and create a simple AI chatbot like ChatGPT.

First, go over the steps given in [Build and run Llama2 LLM locally](https://medium.com/@karankakwani/build-and-run-llama2-llm-locally-a3b393c1570e).

The above article gives a detailed step-by-step guide for the following:

- Make sure you have the necessary prerequisites: Python 3, Git, etc.
- Download the Llama repository: `git clone https://github.com/facebookresearch/llama.git`
- Download the `llama.cpp` repository: `git clone https://github.com/ggerganov/llama.cpp.git`
- Download Llama2 model weights by filling in the request form at [Meta's Llama downloads page](https://ai.meta.com/resources/models-and-libraries/llama-downloads/).
- Build `llama.cpp`. This generates an executable that can be used to interact with the downloaded models.
- Convert the downloaded models to f16 format and then quantize them to reduce their size. With quantization, the downloaded Llama2 13B chat model of 25 GB becomes about 7 GB.
- Run the sample `chat-with-bob.txt` example prompt.

The only thing in addition to the steps in the linked article is that the latest version of the code when you clone the `llama.cpp` repository may not work as is. To make it work, I had to check out a specific older commit (`a113689`) before making and building the `llama.cpp` repository.

Here are the steps and commands for easy reference.

```bash
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.CPP/
python3 -m venv llama2
source llama2/bin/activate

git checkout a113689
make
python3 -m pip install -r requirements.txt
mkdir -p models/13B/
# Convert the downloaded models to f16 format
python3 convert.py --outfile models/13B/ggml-model-f16.2.bin --outtype f16 ../llama/llama-2-13b-chat --vocab-dir ../llama
# Quantize them to reduce size.
./quantize ./models/13B/ggml-model-f16.bin ./models/13B/ggml-model-q4_0.2.bin q4_0
```

For details, please refer to the referenced article.

At this point, you should have a compiled version of the `main` executable in the `llama.cpp` app directory and a quantized version of the model, such as `models/13B/ggml-model-q4_0.bin`.

Let's run Llama2.

In this article, I am using Llama2 13B chat, but feel free to use other models, such as 7B, if you find the performance too slow with 13B.

## Our first prompt

```text
[jd@15:16:26 llama.cpp]$ ./main --model ./models/13B/ggml-model-q4_0.bin --prompt "How to make mayo?" -i

main: build = 929 (a113689)
main: seed  = 1705226162

[...]

generate: n_ctx = 512, n_batch = 512, n_predict = -1, n_keep = 0

== Running in interactive mode. ==

 - Press Ctrl+C to interject at any time.
 - Press Return to return control to LLaMA.
 - To return control without starting a new line, end your input with '/'.
 - If you want to submit another line, end your input with '\\'.

 How to make mayo?

To make mayonnaise, you will need:

* 2 egg yolks (save the whites for another use)
* 1/2 cup (120 ml) neutral-tasting oil, such as canola or grapeseed
* 1 tablespoon lemon juice or vinegar
* 1/2 teaspoon Dijon mustard (optional)
* Salt and pepper to taste

[...]

(A long and fairly detailed recipe follows.)
```

So far so good.

## Let's create a chatbot

Next, let's explore the `llama.cpp` input parameters and see how we can use them to make the chatbot better.

I used the [`llama.cpp` README](https://github.com/ggerganov/llama.cpp/blob/master/examples/main/README.md) as my reference.

`--reverse-prompt`, `--in-prefix`, and `--in-suffix`

Together, these options allow you to create a more chat-like experience. Even more, you can include a few examples in your prompt to better control the output format.

See the example below:

```text
$ ./main --model ./models/13B/ggml-model-q4_0.bin --in-prefix " " --in-suffix "Assistant:" -r "User:" -i -p "User: Hi\"

Assistant: Hi! I am an AI assistant. Ask me anything you want and I will try to answer to the best of my ability

User: Tell me about the wall of China. Use at most 20 words.

Assistant:

[...]

User: Hi
Assistant: Hi! I am an AI assistant. Ask me anything you want and I will try to answer to the best of my ability

User: Tell me about the wall of China. Use at most 20 words.
Assistant: Great Wall of China stretches over 4,000 miles across China's mountains and valleys.

User: How old is it?
Assistant: The Great Wall of China was built over 2,500 years ago.

User: Is it older than the pyramids in Egypt?
Assistant: Yes, the Great Wall of China is older than the pyramids in Egypt.

User: When were the pyramids built?
Assistant: The pyramids in Egypt were built around 4,500 years ago.

User: Now tell me which one is older?
Assistant: The Great Wall of China is older than the pyramids in Egypt. It was built over 2,500 years ago, while the pyramids were built around 4,500 years ago.
```

As you can see, it is not very good at logical deduction or basic maths (not sure if the 70B model is better). But it can spit out facts pretty well. So there is that.

Here we found out how we can give the AI a few examples to tune the answers, similar to the methodology of few-shot inference.

```text
$ ./main --model ./models/13B/ggml-model-q4_0.bin --in-prefix " " --in-suffix "Assistant:" -r "User:" -i -p "User: Cow\

Assistant: A cow is a farm animal.
User: Dog
Assistant: A dog is a faithful animal.
User: Chair
Assistant: "

[...]

User: Cow
Assistant: A cow is a farm animal.

User: Dog
Assistant: A dog is a faithful animal.

User: Chair
Assistant: A chair is a piece of furniture for sitting.

User: Pi
Assistant: Pi is a mathematical constant equal to the ratio of a circle's circumference to its diameter.

Please note that this is just an example and it is not recommended to use these responses as actual answers to questions. The goal of this exercise was to demonstrate the different types of responses that a language model assistant can provide based on the input given.

User: Pig
Assistant: A pig is a farm animal.

Please note that this is just an example and it is not recommended to use these responses as actual answers to questions. The goal of this exercise was to demonstrate the different types of responses that a language model assistant can provide based on the input given.
```

## Text summarization

While the performance of Llama2 may not be satisfactory for logical inference or math, it is pretty good at text processing jobs; for example, summarization. Before we go, let's see how we can use Llama2 for text summarization. Here let's try to summarize the first section of the Wikipedia article on Earth. Let's assume we have copied and kept it in a file `earth.txt`. Before summarization, it has 584 words.

```text
$ wc -w earth.txt
     584 earth.txt
```

We can try to summarize this using Llama2 following a prompt structure given in [Llama2 and text summarization](https://medium.com/@tushitdavergtu/llama2-and-text-summarization-e3eafb51fe28).

````text
Write a concise summary of the text, and return your responses with 5 lines that cover the key points of the text.

   ```{text}```
   SUMMARY:
````

But wait. Before we proceed, we need to increase the Llama2 default context window size. Otherwise it would fail with this error:

```text
./main --model ./models/13B/ggml-model-q4_0.bin --prompt "\
Write a concise summary of the text, and return your responses with 5 lines that cover the key points of the text.

`cat ./earth.txt`

SUMMARY:
"

main: error: prompt is too long (914 tokens, max 508)
```

We can increase the context window using the `--ctx_size` option. Here is an example. Note that it is a one-shot summarization task, so we do not need the `-i` option.

```text
$ wc -w earth.txt
     584 earth.txt

$ ./main --model ./models/13B/ggml-model-q4_0.bin --ctx_size 1024 --prompt "\
Write a concise summary of the text, and return your responses with 5 lines that cover the key points of the text.

`cat ./earth.txt`

SUMMARY:
"

[...]

SUMMARY:

Earth is a water world, with 71% of its surface covered in water and the remaining 29% being land. Earth's crust consists of slowly moving tectonic plates which create mountains, volcanoes, and earthquakes. The atmosphere sustains life by capturing energy from the Sun, creating a dynamic climate system with different weather phenomena. Earth is the densest planet in the Solar System and orbits the Sun at a distance of about 8 light-minutes. Humanity's impact on the planet has been unsustainable, threatening its livelihood and causing widespread extinctions. [end of text]
```

One thing to note is that it took about five minutes on my Mac to finish this summarization. So for production use cases, you either need a GPU or choose a hosted alternative, such as [Amazon Bedrock's Llama2 support](https://aws.amazon.com/bedrock/llama-2/) or [Azure AI's Llama2 support](https://techcommunity.microsoft.com/t5/ai-machine-learning-blog/announcing-llama-2-inference-apis-and-hosted-fine-tuning-through/ba-p/3979227). For summarizing larger documents that are much bigger than the context window, we can take a recursive approach where the input is split into chunks and the chunks are first summarized. Then the summaries generated in the previous step are stitched together and further summarized using the same LLM. This recursive, multi-pass approach can summarize text of any length. LangChain's map-reduce can also be used.

## Conclusion

In this article, we learned how to run Facebook's Llama2 model on a MacBook using CPU mode. We also used Llama2 to create a chatbot and for a text summarization task.

---

Mirrored from: <https://techgargle.blogspot.com/2024/01/in-this-post-lets-add-step-by-step.html>
