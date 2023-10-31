const AudioPlayer = {
  mounted() {
    this.player = null

    this.handleEvent("play", ({ music }) => {
      this.play(music)
    })

    this.handleEvent("pause", ({}) => {
      this.pause()
    })
  },
  destroyed() {
    this.pause()
  },
  play(music) {
    this.pause()

    if (music !== "") {
      this.player = new Audio(music)
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