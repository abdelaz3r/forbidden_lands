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
    if (music !== "") {
      this.pause()

      this.player = new Audio(music)
      this.player.play()

      this.player.addEventListener("ended", () => {
        this.pushEventTo(this.el, "audio-ended")
      })
    } else {
      this.pause()
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