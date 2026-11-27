import { Controller } from "@hotwired/stimulus"
// Connects to data-controller="scroll"
// Garde la conversation en bas quand un message arrive ou s'écrit.
export default class extends Controller {
  connect() {
    this.scrollToBottom()
    this.observer = new MutationObserver(() => {
      if (this.isNearBottom()) this.scrollToBottom()
    })
    this.observer.observe(this.element, {
      childList: true,
      subtree: true,
      characterData: true
    })
  }
  disconnect() {
    this.observer.disconnect()
  }
  scrollToBottom() {
    this.element.scrollTo({ top: this.element.scrollHeight, behavior: "instant" })
  }
  // Si vous êtes remontée lire un ancien message, on ne vous ramène pas en bas.
  isNearBottom() {
    const { scrollHeight, scrollTop, clientHeight } = this.element
    return scrollHeight - scrollTop - clientHeight < 250
  }
}
