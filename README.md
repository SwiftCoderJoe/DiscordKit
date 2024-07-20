# DiscordKit

WIP Discord library for interacting with the Discord API through Swift. DiscordKit is type-safe.

**DO NOT** use DiscordKit in production. DiscordKit **DOES NOT** limit your requests and could get you banned from the discord API. 

A simple example is in `Tests/DiscordKitTests/DiscordKitTests.swift`. The token used there is not active, and you will need to replace it with your own token. It includes three commands: two commands that read messages and scan them for a wake sequence, and one slash command. 

## Featureset

DiscordKit implements basic Discord API interactions. It implements reading messages from a channel, sending messages in a channel, and slash commands that have no interactions.