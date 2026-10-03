using System;
using System.Collections.Generic;
using System.IO;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Media;

namespace XtremeWorlds.Client.Engine.Audio;

/// <summary>
/// FNA audio front-end.  FNA's Audio/Media implementation is backed by FAudio,
/// replacing the old BASS/FMOD path with the same backend FNA uses internally.
/// </summary>
public sealed class FnaAudioService : IDisposable
{
    private readonly Dictionary<string, SoundEffect> _effects = new(StringComparer.OrdinalIgnoreCase);
    private Song? _music;

    public float SoundVolume { get; set; } = 1.0f;

    public float MusicVolume
    {
        get => MediaPlayer.Volume;
        set => MediaPlayer.Volume = Math.Clamp(value, 0f, 1f);
    }

    public void PlaySound(string path)
    {
        if (string.IsNullOrWhiteSpace(path) || !File.Exists(path))
            return;

        FrameworkDispatcher.Update();
        if (!_effects.TryGetValue(path, out var effect))
        {
            using var stream = File.OpenRead(path);
            effect = SoundEffect.FromStream(stream);
            _effects[path] = effect;
        }
        effect.Play(Math.Clamp(SoundVolume, 0f, 1f), 0f, 0f);
    }

    public void PlayMusic(string path, bool loop = true)
    {
        if (string.IsNullOrWhiteSpace(path) || !File.Exists(path))
            return;

        FrameworkDispatcher.Update();
        StopMusic();
        var fullPath = Path.GetFullPath(path);
        _music = Song.FromUri(Path.GetFileNameWithoutExtension(fullPath), new Uri(fullPath));
        MediaPlayer.IsRepeating = loop;
        MediaPlayer.Play(_music);
    }

    public void StopMusic()
    {
        if (MediaPlayer.State != MediaState.Stopped)
            MediaPlayer.Stop();
        _music?.Dispose();
        _music = null;
    }

    public void Dispose()
    {
        StopMusic();
        foreach (var effect in _effects.Values)
            effect.Dispose();
        _effects.Clear();
    }
}
