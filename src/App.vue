<template>
  <v-alert density="compact" type="error" v-show="errorInfo != ''">{{ errorInfo }}</v-alert>

  <div class="text-center" v-show="loading">
    <v-progress-circular indeterminate color="primary"></v-progress-circular>
  </div>

  <div class="md-content" v-show="!loading">
    <div id="tags" v-html="tagsValue"></div>
    <br />
    <div v-html="outputValue"></div>
  </div>
</template>


<script>
import { defineComponent } from 'vue'

import {
  nip19,
  SimplePool,
} from 'nostr-tools'

import hljs from 'highlight.js'
import 'highlight.js/styles/github.css'
import MarkdownIt from 'markdown-it'
import mathjax3 from 'markdown-it-mathjax3'
import MarkdownItEmoji from 'markdown-it-emoji'

const md = new MarkdownIt({
  html: true,
  linkify: true,
  typographer: true,
  breaks: true,
  highlight(code, lang) {
    console.log(lang, code);
    // https://github.com/WongSaang/chatgpt-ui/blob/73536144726eb1e3cb37a72cc7861da02b1304cc/components/MsgContent.vue
    const language = hljs.getLanguage(lang) ? lang : 'plaintext'
    return `<pre class="hljs-code-container"><code class="hljs language-${language}">${hljs.highlight(code, { language: language, ignoreIllegals: true }).value}</code></pre>`
  },
})
  .use(mathjax3)
  .use(MarkdownItEmoji);


export default defineComponent({
  data() {
    return {
      loading: true,
      inputValue: '',
      errorInfo: '',
      outputValue: '',
      tagsValue: '',
      pool: new SimplePool(),
      relays: ['wss://nos.lol/', 'wss://relay.damus.io/'],
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

    onEvent(event) {
      console.log('we got the event we wanted:', event);
      this.inputValue = event.content;
    },
  },

  watch: {
    inputValue(value) {
      this.loading = true;
      this.render(value);
      this.loading = false;
    },
  },

  mounted() {

  },

  created() {
    try {
      const m = document.location.search.match(/(?<=note=)note[\da-z]+/);
      if (!m || m.length == 0) {
        this.errorInfo = `链接错误，例如 ${document.location.protocol}//${document.location.host}${document.location.pathname}?note=note1z3vmxymn3yj6jgyzxw6tmx06gsc36rjfa77p5edecveaamzfpd7s8v26m3`; /* cspell: disable-line */
        return;
      }

      const n = nip19.decode(m[0]);
      if (!n || !n.data) {
        this.errorInfo = 'nip19';
        return;
      }

      let sub = this.pool.sub(
        this.relays,
        [
          {
            ids: [n.data]
          }
        ]);
      sub.on('event', this.onEvent);
    } catch (error) {
      this.errorInfo = error;
    }

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

.md-content {
  margin: 8px;
  /* font-size: 0.875rem !important; */
  /* font-weight: 400; */
  line-height: 1.25rem;
}

.md-content p,
.md-content table,
.md-content ul,
.md-content ol {
  margin-bottom: 1rem;
}

.md-content h1,
.md-content hr {
  margin-top: 8px;
  margin-bottom: 8px;
}

.md-content h2 {
  margin-top: 7px;
  margin-bottom: 7px;
}

.md-content h3 {
  margin-top: 6px;
  margin-bottom: 6px;
}

.md-content h4 {
  margin-top: 5px;
  margin-bottom: 5px;
}

.md-content h3 {
  margin-top: 4px;
  margin-bottom: 4px;
}

.md-content table,
.md-content img {
  width: 100%;
  border-collapse: collapse;
  border-radius: .5rem;
}

.md-content table th,
.md-content table td {
  padding: .5rem 1rem;
  border: 1px solid gray;
}

.md-content ol,
.md-content ul {
  padding-left: 2em;
}

.md-content p>code {
  padding: 2px 4px;
  font-size: 90%;
  color: #c7254e;
  background-color: #f9f2f4;
  border-radius: 4px;
}

.md-content pre {
  margin-bottom: 10px;
}

.md-content pre>code {
  background-color: #e6e6e6;
}

.hljs {
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
<style>
.v-progress-circular {
  margin: 1rem;
}
</style>