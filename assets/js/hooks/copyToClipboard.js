const CopyToClipboard = {
  mounted() {
    const button = this.el
    const { to, valueSuccess, valueError } = button.dataset

    button.addEventListener('click', (e) => {
      e.preventDefault()

      const text = document.querySelector(to).value

      navigator.clipboard.writeText(text).then(
        () => { button.textContent = valueSuccess },
        () => { button.textContent = valueError }
      )
    })
  }
}

export default CopyToClipboard