package expo.modules.fileopener

import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import expo.modules.kotlin.exception.CodedException
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class NoViewerException :
  CodedException("Nenhum aplicativo pode abrir este arquivo")

class FileOpenerModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("FileOpener")

    AsyncFunction("openAsync") { uri: String, mimeType: String, _: String ->
      val context = appContext.throwingActivity
      val contentUri = Uri.parse(uri)
      val type = mimeType.ifBlank { "*/*" }
      val view = Intent(Intent.ACTION_VIEW).apply {
        setDataAndType(contentUri, type)
        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        clipData = ClipData.newRawUri("", contentUri)
      }

      val match =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PackageManager.MATCH_ALL else 0
      val resolved = context.packageManager.queryIntentActivities(view, match)
      resolved.forEach {
        context.grantUriPermission(
          it.activityInfo.packageName,
          contentUri,
          Intent.FLAG_GRANT_READ_URI_PERMISSION,
        )
      }

      val chooser = Intent.createChooser(view, "Abrir com").apply {
        clipData = ClipData.newRawUri("", contentUri)
        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
      }
      try {
        context.startActivity(chooser)
      } catch (_: ActivityNotFoundException) {
        throw NoViewerException()
      }
    }
  }
}
