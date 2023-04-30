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

const md = new MarkdownIt({
  html: true,
  linkify: true,
  typographer: true,
  breaks: true,
  highlight(code, lang) {
    // https://github.com/WongSaang/chatgpt-ui/blob/73536144726eb1e3cb37a72cc7861da02b1304cc/components/MsgContent.vue
    const language = hljs.getLanguage(lang) ? lang : 'plaintext'
    return `<pre class="hljs-code-container my-3"><div class="hljs-code-header d-flex align-center justify-space-between bg-grey-darken-3 pa-1"><span class="pl-2 text-caption">${language}</span><button class="hljs-copy-button" data-copied="false">Copy</button></div><code class="hljs language-${language}">${hljs.highlight(code, { language: language, ignoreIllegals: true }).value}</code></pre>`
  },
});


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
  font-size: 0.875rem !important;
  font-weight: 400;
  line-height: 1.25rem;
}

.md-content p,
.md-content table,
.md-content ul,
.md-content ol,
.md-content h1,
.md-content h2,
.md-content h3,
.md-content h4,
.md-content h5,
.md-content h6 {
  margin-bottom: 1rem;
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

.hljs-code-container {
  border-radius: 3px;
  overflow: hidden;
}

.hljs-copy-button {
  width: 2rem;
  height: 2rem;
  text-indent: -9999px;
  color: #fff;
  border-radius: .25rem;
  border: 1px solid #ffffff22;
  background-image: url('data:image/svg+xml;utf-8,<svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M6 5C5.73478 5 5.48043 5.10536 5.29289 5.29289C5.10536 5.48043 5 5.73478 5 6V20C5 20.2652 5.10536 20.5196 5.29289 20.7071C5.48043 20.8946 5.73478 21 6 21H18C18.2652 21 18.5196 20.8946 18.7071 20.7071C18.8946 20.5196 19 20.2652 19 20V6C19 5.73478 18.8946 5.48043 18.7071 5.29289C18.5196 5.10536 18.2652 5 18 5H16C15.4477 5 15 4.55228 15 4C15 3.44772 15.4477 3 16 3H18C18.7956 3 19.5587 3.31607 20.1213 3.87868C20.6839 4.44129 21 5.20435 21 6V20C21 20.7957 20.6839 21.5587 20.1213 22.1213C19.5587 22.6839 18.7957 23 18 23H6C5.20435 23 4.44129 22.6839 3.87868 22.1213C3.31607 21.5587 3 20.7957 3 20V6C3 5.20435 3.31607 4.44129 3.87868 3.87868C4.44129 3.31607 5.20435 3 6 3H8C8.55228 3 9 3.44772 9 4C9 4.55228 8.55228 5 8 5H6Z" fill="white"/><path fill-rule="evenodd" clip-rule="evenodd" d="M7 3C7 1.89543 7.89543 1 9 1H15C16.1046 1 17 1.89543 17 3V5C17 6.10457 16.1046 7 15 7H9C7.89543 7 7 6.10457 7 5V3ZM15 3H9V5H15V3Z" fill="white"/></svg>');
  background-repeat: no-repeat;
  background-position: center;
  transition: background-color 200ms ease, transform 200ms ease-out
}

.hljs-copy-button:hover {
  border-color: #ffffff44
}

.hljs-copy-button:active {
  border-color: #ffffff66
}

.hljs-copy-button[data-copied="true"] {
  text-indent: 0;
  width: auto;
  background-image: none
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
}</style>
<style>.v-progress-circular {
  margin: 1rem;
}</style>