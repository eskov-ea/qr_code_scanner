package com.mcfef.cashalot.qrs_scaner

import android.app.Service
import android.content.Context
import android.content.res.AssetFileDescriptor
import android.media.AudioAttributes
import android.media.AudioDeviceInfo
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build

class QRAudioManager constructor(var context: Context) {
    private var audioManager: AudioManager = context.getSystemService(Service.AUDIO_SERVICE) as AudioManager
    private var mediaPlayer: MediaPlayer? = null
    private val outputDevice: Int = AudioDeviceInfo.TYPE_BUILTIN_SPEAKER
    private var beepDescriptor: AssetFileDescriptor? = null
    private var errorDescriptor: AssetFileDescriptor? = null
    private val afChangeListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
        when (focusChange) {
            AudioManager.AUDIOFOCUS_LOSS -> {
                println("Audio focus event:: AUDIOFOCUS_LOSS")
            }

            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                println("Audio focus event:: AUDIOFOCUS_LOSS_TRANSIENT")
            }

            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                println("Audio focus event:: AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK")
            }

            AudioManager.AUDIOFOCUS_GAIN -> {
                println("Audio focus event:: AUDIOFOCUS_GAIN")
            }
        }
    }

    init {
        openDescriptor()
    }

    private fun openDescriptor() {
        beepDescriptor = context.resources.assets.openFd("scanner_beep_sound.mp3")
        errorDescriptor = context.resources.assets.openFd("scanner_error_sound.mp3")
    }

    private fun requestAudioFocus() {
        audioManager.mode = AudioManager.MODE_NORMAL

        audioManager.requestAudioFocus(
            AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                .setAcceptsDelayedFocusGain(true)
                .setOnAudioFocusChangeListener(afChangeListener)
                .build()
        )
    }


    fun playBeepSound() {
        try {
            if (beepDescriptor == null) {
                openDescriptor()
            }
            requestAudioFocus()

            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .build()
                )
            }
            mediaPlayer!!.setDataSource(
                beepDescriptor!!.fileDescriptor,
                beepDescriptor!!.startOffset,
                beepDescriptor!!.length
            )
            mediaPlayer!!.prepare()
            mediaPlayer!!.setVolume(1f, 1f)
            mediaPlayer!!.isLooping = false
            mediaPlayer!!.start()
        } catch (error: Exception) {
            println("Playing connecting sound error: ${error.localizedMessage}\r\n${error.stackTraceToString()}")
        }
    }

    fun playErrorSound() {
        try {
            if (errorDescriptor == null) {
                openDescriptor()
            }
            requestAudioFocus()

            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .build()
                )
            }
            mediaPlayer!!.setDataSource(
                errorDescriptor!!.fileDescriptor,
                errorDescriptor!!.startOffset,
                errorDescriptor!!.length
            )
            mediaPlayer!!.prepare()
            mediaPlayer!!.setVolume(1f, 1f)
            mediaPlayer!!.isLooping = false
            mediaPlayer!!.start()
        } catch (error: Exception) {
            println("Playing connecting sound error: ${error.localizedMessage}\r\n${error.stackTraceToString()}")
        }
    }
}