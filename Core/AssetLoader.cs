using System;
using System.IO;
using System.Linq;
using Eto.Drawing;

namespace XtremeWorlds.Client.UI
{
    public sealed class AssetLoader
    {
        private AssetLoader()
        {
        }

        public static Image LoadImage(string relativePath)
        {
            if (string.IsNullOrWhiteSpace(relativePath))
                return null;

            // First try the resource embedded in the shared Eto.Core assembly.
            var embedded = LoadEmbeddedImage(relativePath);
            if (embedded is not null)
                return embedded;

            // Also ship the image files physically with the application.  This
            // makes development/debug builds robust even when a resource name is
            // changed by the build system or another host assembly is used.
            var physical = LoadFileImage(relativePath);
            if (physical is not null)
                return physical;

            return null;
        }

        private static Image LoadEmbeddedImage(string relativePath)
        {
            var asm = typeof(AssetLoader).Assembly;
            string normalizedPath = "Assets." + relativePath.Replace("/", ".").Replace(@"\", ".");

            string resourceName = asm.GetManifestResourceNames().FirstOrDefault(n => string.Equals(n, normalizedPath, StringComparison.OrdinalIgnoreCase) || n.EndsWith("." + normalizedPath, StringComparison.OrdinalIgnoreCase));

            if (resourceName is null)
                return null;

            using (var stream = asm.GetManifestResourceStream(resourceName))
            {
                if (stream is null)
                    return null;
                return new Bitmap(stream);
            }
        }

        private static Image LoadFileImage(string relativePath)
        {
            string normalizedRelative = relativePath.Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);
            string[] candidates = new[] { Path.Combine(AppContext.BaseDirectory, "Assets", normalizedRelative), Path.Combine(AppContext.BaseDirectory, normalizedRelative), Path.Combine(Environment.CurrentDirectory, "Assets", normalizedRelative) };

            foreach (var candidate in candidates)
            {
                if (File.Exists(candidate))
                {
                    using (var stream = File.OpenRead(candidate))
                    {
                        return new Bitmap(stream);
                    }
                }
            }

            return null;
        }

        public static Icon LoadIcon(string relativePath)
        {
            if (string.IsNullOrWhiteSpace(relativePath))
                return null;

            var asm = typeof(AssetLoader).Assembly;
            string normalizedPath = "Assets." + relativePath.Replace("/", ".").Replace(@"\", ".");
            string resourceName = asm.GetManifestResourceNames().FirstOrDefault(n => string.Equals(n, normalizedPath, StringComparison.OrdinalIgnoreCase) || n.EndsWith("." + normalizedPath, StringComparison.OrdinalIgnoreCase));

            if (resourceName is not null)
            {
                using (var stream = asm.GetManifestResourceStream(resourceName))
                {
                    if (stream is not null)
                        return new Icon(stream);
                }
            }

            string normalizedRelative = relativePath.Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);
            string[] candidates = new[] { Path.Combine(AppContext.BaseDirectory, "Assets", normalizedRelative), Path.Combine(AppContext.BaseDirectory, normalizedRelative), Path.Combine(Environment.CurrentDirectory, "Assets", normalizedRelative) };
            foreach (var candidate in candidates)
            {
                if (File.Exists(candidate))
                    return new Icon(candidate);
            }
            return null;
        }
    }
}