import { Controller } from "@hotwired/stimulus"

export default class GameWon extends Controller {
    initialize() {
    }

    connect() {
      const jsConfetti = new JSConfetti();
      jsConfetti.addConfetti({
        emojis: ['❤️', '💎'],
        emojiSize: 50,
        confettiNumber: 60
      });
    }

    disconnect() {

    }
}