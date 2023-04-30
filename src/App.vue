<template>
  <!-- <router-view /> -->
  <div>
    <textarea rows="10" cols="80" id="input" v-model="inputValue"></textarea>
    <div id="tags" v-html="tagsValue"></div>
    <div v-html="outputValue"></div>
  </div>
</template>


<script>
import { defineComponent } from 'vue'

import hljs from 'highlight.js';
import 'highlight.js/styles/github.css';
import MarkdownIt from 'markdown-it';
const md = new MarkdownIt({
  html: true,
  linkify: true,
  typographer: true,
  breaks: true,
  highlight: function (str, lang) {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return '<pre class="hljs"><code>' +
               hljs.highlight(str, { language: lang, ignoreIllegals: true }).value +
               '</code></pre>';
      } catch (__) { /* empty */ }
    }

    return '<pre class="hljs"><code>' + md.utils.escapeHtml(str) + '</code></pre>';
  }
});

export default defineComponent({
  data() {
    return {
      inputValue: '',
      outputValue: '',
      tagsValue: '',
    };
  },
  methods: {
    render(value) {
      const tagRegex = /^#[\w\d]+(?= *$)/mg;
      const matches = value.match(tagRegex);
      if (matches) {
        const uniqueTags = [...new Set(matches)];
        this.tagsValue = uniqueTags.map(tag => `<div class="tag"><a href="https://snort.social/t/${tag}" target="_blank">${tag}</a></div>`).join('');
      } else {
        this.tagsValue = '';
      }

      const replacedMarkdown = value.replace(/\n^#[\w\d]+ *$/mg, '').replace(/^#[\w\d]+ *$\n/mg, '').replace(/^#[\w\d]+ *$/mg, '');
      this.outputValue = md.render(replacedMarkdown);
    },
  },
  watch: {
    inputValue(value) {
      this.render(value)
    },
  },
  mounted() {
    this.render(this.inputValue)
  },
});
</script>

<style>
.tag {
  display: inline-block;
  padding: 5px 10px;
  margin-right: 10px;
  background-color: #f2f2f2;
  border-radius: 5px;
  cursor: pointer;
}

.tag:hover {
  background-color: #e6e6e6;
}
</style>
<style rel="stylesheet">
blockquote {
  padding: 0 0 0 15px;
  margin: 0 0 22px;
  border-left: 5px solid #ccc;
}

blockquote p {
  margin-bottom: 0;
}

blockquote small {
  display: block;
  line-height: 22px;
  color: #999;
}

blockquote small:before {
  content: '\2014 \00A0';
}

blockquote.pull-right {
  float: right;
  padding-left: 0;
  padding-right: 15px;
  border-left: 0;
  border-right: 5px solid #ccc;
}

blockquote.pull-right p,
blockquote.pull-right small {
  text-align: right;
}

q:before,
q:after,
blockquote:before,
blockquote:after {
  content: "";
}
</style>