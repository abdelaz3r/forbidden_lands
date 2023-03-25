const AudioPlayer = {
  mounted() {
    this.player = null
    this.play()
  },
  updated() {
    this.play()
  },
  destroyed() {
    this.pause()
  },
  play() {
    if (this.el.dataset.source && this.el.dataset.source !== "") {
      this.pause()

      this.player = new Audio(this.el.dataset.source)
      this.player.play()

      this.player.addEventListener("ended", () => {
        this.pushEventTo(this.el, "audio-ended")
      })
    }
  },
  pause() {
    if (this.player) {
      this.player.removeEventListener("ended", () => {
        this.pushEventTo(this.el, "audio-ended")
      })

      this.player.pause()
    }
  }
}

export default AudioPlayer