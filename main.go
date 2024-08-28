package main

import (
	"log"

	"github.com/ansrivas/fiberprometheus/v2"

	"github.com/gofiber/fiber/v2"
)

func TestPass() bool {
	return true
}
func main() {
	app := fiber.New()
	prometheus := fiberprometheus.New("my-service-name")
	prometheus.RegisterAt(app, "/metrics")
	prometheus.SetSkipPaths([]string{"/ping"}) // Optional: Remove some paths from metrics
	app.Use(prometheus.Middleware)
	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, UPDATE1!")
	})
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.SendString("OK")
	})
	app.Get("/ping", func(c *fiber.Ctx) error {
		return c.SendString("pong")
	})

	log.Fatal(app.Listen(":8080"))
}
