import AVFoundation

/// Sound effects available in the game
public enum SoundEffect: String, CaseIterable {
    case tileMove = "tile_move"
    case tileMerge = "tile_merge"
    case win = "win"
    case gameOver = "game_over"
}

/// Available music tracks for background music
public enum MusicTrack: String, CaseIterable, Sendable {
    case chill = "background_music"
    case none = "none"

    public var displayName: String {
        switch self {
        case .chill: return "Chill"
        case .none: return "No Music"
        }
    }

    public var icon: String {
        switch self {
        case .chill: return "music.note"
        case .none: return "speaker.slash"
        }
    }
}

/// Singleton manager for background music and sound effects
/// Uses AVFoundation for audio playback with proper iOS audio session handling
@MainActor
@Observable
public final class AudioManager: Sendable {
    public static let shared = AudioManager()

    // MARK: - State

    /// Whether background music is enabled (persisted in UserDefaults)
    public var isMusicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: "isMusicEnabled")
            updateMusicState()
        }
    }

    /// Whether sound effects are enabled (persisted in UserDefaults)
    public var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "isSoundEnabled")
        }
    }

    /// Current music track (persisted in UserDefaults)
    public var currentTrack: MusicTrack {
        didSet {
            UserDefaults.standard.set(currentTrack.rawValue, forKey: "currentMusicTrack")
            if currentTrack == .none {
                stopBackgroundMusic()
            } else {
                switchToTrack(currentTrack)
            }
        }
    }

    // MARK: - Private Properties

    private var musicPlayer: AVAudioPlayer?
    private var soundPlayers: [SoundEffect: AVAudioPlayer] = [:]

    // MARK: - Initialization

    private init() {
        // Load persisted settings (default to true if not set)
        let storedMusicEnabled = UserDefaults.standard.object(forKey: "isMusicEnabled")
        let storedSoundEnabled = UserDefaults.standard.object(forKey: "isSoundEnabled")
        let storedTrack = UserDefaults.standard.string(forKey: "currentMusicTrack")

        self.isMusicEnabled = (storedMusicEnabled as? Bool) ?? true
        self.isSoundEnabled = (storedSoundEnabled as? Bool) ?? true
        self.currentTrack = MusicTrack(rawValue: storedTrack ?? "") ?? .chill

        setupAudioSession()
        preloadSounds()
    }

    // MARK: - Audio Session

    private func setupAudioSession() {
        #if os(iOS)
        do {
            // Configure audio session for game sounds mixed with other apps
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioManager: Failed to setup audio session - \(error.localizedDescription)")
        }
        #endif
    }

    // MARK: - Background Music

    /// Starts playing background music in a loop
    public func playBackgroundMusic() {
        guard isMusicEnabled else { return }
        guard currentTrack != .none else { return }
        guard musicPlayer == nil || !(musicPlayer?.isPlaying ?? false) else { return }

        playTrack(currentTrack)
    }

    /// Switches to a different music track
    private func switchToTrack(_ track: MusicTrack) {
        stopBackgroundMusic()
        guard isMusicEnabled && track != .none else { return }
        playTrack(track)
    }

    /// Plays a specific track
    private func playTrack(_ track: MusicTrack) {
        // Try mp3 first, then m4a
        var url = Bundle.module.url(forResource: track.rawValue, withExtension: "mp3")
        if url == nil {
            url = Bundle.module.url(forResource: track.rawValue, withExtension: "m4a")
        }
        guard let musicUrl = url else {
            print("AudioManager: Music file \(track.rawValue) not found")
            return
        }

        do {
            musicPlayer = try AVAudioPlayer(contentsOf: musicUrl)
            musicPlayer?.numberOfLoops = -1 // Loop indefinitely
            musicPlayer?.volume = 0.3 // Lower volume for background
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            print("AudioManager: Failed to play music - \(error.localizedDescription)")
        }
    }

    /// Stops background music
    public func stopBackgroundMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    /// Updates music playback based on enabled state
    private func updateMusicState() {
        if isMusicEnabled {
            playBackgroundMusic()
        } else {
            stopBackgroundMusic()
        }
    }

    // MARK: - Sound Effects

    /// Preloads all sound effects for instant playback
    private func preloadSounds() {
        for sound in SoundEffect.allCases {
            let fileExtension = sound == .tileMove || sound == .tileMerge ? "wav" : "wav"
            guard let url = Bundle.module.url(forResource: sound.rawValue, withExtension: fileExtension) else {
                continue
            }

            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                soundPlayers[sound] = player
            } catch {
                print("AudioManager: Failed to preload \(sound.rawValue) - \(error.localizedDescription)")
            }
        }
    }

    /// Plays a sound effect
    public func playSound(_ sound: SoundEffect) {
        guard isSoundEnabled else { return }

        // If sound is already loaded, play it
        if let player = soundPlayers[sound] {
            // Reset to beginning and play
            player.currentTime = 0
            player.play()
            return
        }

        // Fallback: try to load and play on demand
        guard let url = Bundle.module.url(forResource: sound.rawValue, withExtension: "wav") else {
            print("AudioManager: Sound file \(sound.rawValue).wav not found")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()
            soundPlayers[sound] = player
        } catch {
            print("AudioManager: Failed to play sound \(sound.rawValue) - \(error.localizedDescription)")
        }
    }
}
