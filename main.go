package main

import (
	"log"

	"github.com/gofiber/fiber/v2"
)

func TestPass() bool {
	return true
}
func main() {
	app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, UPDATE1!")
	})
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.SendString("OK")
	})

	log.Fatal(app.Listen(":8080"))
}
