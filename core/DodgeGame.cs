using Godot;
using System;
using Arch;
using Arch.Core;

public record struct Position(float X, float Y);
public class DodgeGame
{
    public World Ecs { get; private set; } = World.Create();
    public Entity NewGame()
    {
        this.Ecs.Clear();
        var player = this.Ecs.Create(new Position(0, 0));
        return player;
    }
}
