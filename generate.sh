#!/bin/bash

set -eu

SDK_PATH="$(sed -En 's/^\s*sdk.dir=(.*)$/\1/p' local.properties)"
SDK_VERSION="$(sed -En 's/^\s*compileSdkVersion\s+([0-9]+)\s*$/\1/p' library/build.gradle)"
SDK_JAVA_SOURCE_ROOT="${SDK_PATH}/sources/android-${SDK_VERSION}"
LIBRARY_JAVA_SOURCE_ROOT="library/src/main/java"

mkdir -p "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file"
rm -rf "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file"
cp -r "${SDK_JAVA_SOURCE_ROOT}/java/nio/file" "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file"

find "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file" -iname '*.java' -type f -print0 | xargs -0 sed -Ei \
-e 's/\bjava\.nio\.file\b/java8.nio.file/g' \
-e 's/\bjava\.time\b/org.threeten.bp/g' \
-e 's/\bMath(\.floor(Div|Mod))\b/org.threeten.bp.jdk8.Jdk8Methods\1/g' \
-e 's/\bObjects(\.requireNonNull)\b/org.threeten.bp.jdk8.Jdk8Methods\1/g' \
-e 's/\bjava(\.util\.(Spliterators?|function|stream))\b/java9\1/g' \
-e '/^\s*import(\s+static)?\s+sun\..+\s*;\s*$/d' \

mkdir -p "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/channels"
rm -rf "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/channels"
mkdir "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/channels"
cp "${SDK_JAVA_SOURCE_ROOT}/java/nio/channels/SeekableByteChannel.java" "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/channels/SeekableByteChannel.java"
sed -Ei \
-e "s/^(\s*package\s+)java(\.nio\.channels\s*;\s*)$/\1java8\2/" \
-e '/^\s*import\s+java\.nio\.ByteBuffer\s*;\s*$/a\import java.nio.channels.*;' \
"${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/channels/SeekableByteChannel.java"
cat >"${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/channels/FileChannel.java" <<EOF
/*
 * Copyright (c) 2000, 2013, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.  Oracle designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the LICENSE file that accompanied this code.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have any
 * questions.
 */

package java8.nio.channels;

import java.io.IOException;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import java8.nio.file.OpenOption;
import java8.nio.file.Path;
import java8.nio.file.StandardOpenOption;
import java8.nio.file.attribute.FileAttribute;
import java8.nio.file.spi.FileSystemProvider;

public abstract class FileChannel extends java.nio.channels.FileChannel {

    protected FileChannel() {}

    /**
     * Opens or creates a file, returning a file channel to access the file.
     *
     * <p> The {@code options} parameter determines how the file is opened.
     * The {@link StandardOpenOption#READ READ} and {@link StandardOpenOption#WRITE
     * WRITE} options determine if the file should be opened for reading and/or
     * writing. If neither option (or the {@link StandardOpenOption#APPEND APPEND}
     * option) is contained in the array then the file is opened for reading.
     * By default reading or writing commences at the beginning of the file.
     *
     * <p> In the addition to {@code READ} and {@code WRITE}, the following
     * options may be present:
     *
     * <table border=1 cellpadding=5 summary="">
     * <tr> <th>Option</th> <th>Description</th> </tr>
     * <tr>
     *   <td> {@link StandardOpenOption#APPEND APPEND} </td>
     *   <td> If this option is present then the file is opened for writing and
     *     each invocation of the channel's {@code write} method first advances
     *     the position to the end of the file and then writes the requested
     *     data. Whether the advancement of the position and the writing of the
     *     data are done in a single atomic operation is system-dependent and
     *     therefore unspecified. This option may not be used in conjunction
     *     with the {@code READ} or {@code TRUNCATE_EXISTING} options. </td>
     * </tr>
     * <tr>
     *   <td> {@link StandardOpenOption#TRUNCATE_EXISTING TRUNCATE_EXISTING} </td>
     *   <td> If this option is present then the existing file is truncated to
     *   a size of 0 bytes. This option is ignored when the file is opened only
     *   for reading. </td>
     * </tr>
     * <tr>
     *   <td> {@link StandardOpenOption#CREATE_NEW CREATE_NEW} </td>
     *   <td> If this option is present then a new file is created, failing if
     *   the file already exists. When creating a file the check for the
     *   existence of the file and the creation of the file if it does not exist
     *   is atomic with respect to other file system operations. This option is
     *   ignored when the file is opened only for reading. </td>
     * </tr>
     * <tr>
     *   <td > {@link StandardOpenOption#CREATE CREATE} </td>
     *   <td> If this option is present then an existing file is opened if it
     *   exists, otherwise a new file is created. When creating a file the check
     *   for the existence of the file and the creation of the file if it does
     *   not exist is atomic with respect to other file system operations. This
     *   option is ignored if the {@code CREATE_NEW} option is also present or
     *   the file is opened only for reading. </td>
     * </tr>
     * <tr>
     *   <td > {@link StandardOpenOption#DELETE_ON_CLOSE DELETE_ON_CLOSE} </td>
     *   <td> When this option is present then the implementation makes a
     *   <em>best effort</em> attempt to delete the file when closed by the
     *   the {@link #close close} method. If the {@code close} method is not
     *   invoked then a <em>best effort</em> attempt is made to delete the file
     *   when the Java virtual machine terminates. </td>
     * </tr>
     * <tr>
     *   <td>{@link StandardOpenOption#SPARSE SPARSE} </td>
     *   <td> When creating a new file this option is a <em>hint</em> that the
     *   new file will be sparse. This option is ignored when not creating
     *   a new file. </td>
     * </tr>
     * <tr>
     *   <td> {@link StandardOpenOption#SYNC SYNC} </td>
     *   <td> Requires that every update to the file's content or metadata be
     *   written synchronously to the underlying storage device. (see <a
     *   href="../file/package-summary.html#integrity"> Synchronized I/O file
     *   integrity</a>). </td>
     * </tr>
     * <tr>
     *   <td> {@link StandardOpenOption#DSYNC DSYNC} </td>
     *   <td> Requires that every update to the file's content be written
     *   synchronously to the underlying storage device. (see <a
     *   href="../file/package-summary.html#integrity"> Synchronized I/O file
     *   integrity</a>). </td>
     * </tr>
     * </table>
     *
     * <p> An implementation may also support additional options.
     *
     * <p> The {@code attrs} parameter is an optional array of file {@link
     * FileAttribute file-attributes} to set atomically when creating the file.
     *
     * <p> The new channel is created by invoking the {@link
     * FileSystemProvider#newFileChannel newFileChannel} method on the
     * provider that created the {@code Path}.
     *
     * @param   path
     *          The path of the file to open or create
     * @param   options
     *          Options specifying how the file is opened
     * @param   attrs
     *          An optional list of file attributes to set atomically when
     *          creating the file
     *
     * @return  A new file channel
     *
     * @throws  IllegalArgumentException
     *          If the set contains an invalid combination of options
     * @throws  UnsupportedOperationException
     *          If the {@code path} is associated with a provider that does not
     *          support creating file channels, or an unsupported open option is
     *          specified, or the array contains an attribute that cannot be set
     *          atomically when creating the file
     * @throws  IOException
     *          If an I/O error occurs
     * @throws  SecurityException
     *          If a security manager is installed and it denies an
     *          unspecified permission required by the implementation.
     *          In the case of the default provider, the {@link
     *          SecurityManager#checkRead(String)} method is invoked to check
     *          read access if the file is opened for reading. The {@link
     *          SecurityManager#checkWrite(String)} method is invoked to check
     *          write access if the file is opened for writing
     *
     * @since   1.7
     */
    public static FileChannel open(Path path,
                                   Set<? extends OpenOption> options,
                                   FileAttribute<?>... attrs)
            throws IOException
    {
        FileSystemProvider provider = path.getFileSystem().provider();
        return provider.newFileChannel(path, options, attrs);
    }

    @SuppressWarnings({"unchecked", "rawtypes"}) // generic array construction
    private static final FileAttribute<?>[] NO_ATTRIBUTES = new FileAttribute[0];

    /**
     * Opens or creates a file, returning a file channel to access the file.
     *
     * <p> An invocation of this method behaves in exactly the same way as the
     * invocation
     * <pre>
     *     fc.{@link #open(Path,Set,FileAttribute[]) open}(file, opts, new FileAttribute&lt;?&gt;[0]);
     * </pre>
     * where {@code opts} is a set of the options specified in the {@code
     * options} array.
     *
     * @param   path
     *          The path of the file to open or create
     * @param   options
     *          Options specifying how the file is opened
     *
     * @return  A new file channel
     *
     * @throws  IllegalArgumentException
     *          If the set contains an invalid combination of options
     * @throws  UnsupportedOperationException
     *          If the {@code path} is associated with a provider that does not
     *          support creating file channels, or an unsupported open option is
     *          specified
     * @throws  IOException
     *          If an I/O error occurs
     * @throws  SecurityException
     *          If a security manager is installed and it denies an
     *          unspecified permission required by the implementation.
     *          In the case of the default provider, the {@link
     *          SecurityManager#checkRead(String)} method is invoked to check
     *          read access if the file is opened for reading. The {@link
     *          SecurityManager#checkWrite(String)} method is invoked to check
     *          write access if the file is opened for writing
     *
     * @since   1.7
     */
    public static FileChannel open(Path path, OpenOption... options)
            throws IOException
    {
        Set<OpenOption> set = new HashSet<OpenOption>(options.length);
        Collections.addAll(set, options);
        return open(path, set, NO_ATTRIBUTES);
    }

    @Override
    public abstract FileChannel position(long newPosition) throws IOException;

    @Override
    public abstract FileChannel truncate(long size) throws IOException;
}
EOF
find "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file" -iname '*.java' -type f -print0 | xargs -0 sed -Ei \
-e "s/\bjava(\.nio\.channels\.(File|SeekableByte)Channel)\b/java8\1/g" \
-e "/^\s*import\s+java\.nio\.channels\.\*\s*;\s*$/a\import java8.nio.channels.FileChannel;\nimport java8.nio.channels.SeekableByteChannel;"

mkdir -p "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/charset"
rm -rf "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/charset"
mkdir "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/charset"
cp "${SDK_JAVA_SOURCE_ROOT}/java/nio/charset/StandardCharsets.java" "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/charset/StandardCharsets.java"
sed -Ei \
-e "s/^(\s*package\s+)java(\.nio\.charset\s*;\s*)$/\1java8\2\n\nimport java.nio.charset.*;/" \
"${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/charset/StandardCharsets.java"
find "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file" -iname '*.java' -type f -print0 | xargs -0 sed -Ei \
-e 's/\bjava(\.nio\.charset\.StandardCharsets)\b/java8\1/g'

mkdir -p "${LIBRARY_JAVA_SOURCE_ROOT}/java8/io"
rm -rf "${LIBRARY_JAVA_SOURCE_ROOT}/java8/io"
mkdir "${LIBRARY_JAVA_SOURCE_ROOT}/java8/io"
cp "${SDK_JAVA_SOURCE_ROOT}/java/io/UncheckedIOException.java" "${LIBRARY_JAVA_SOURCE_ROOT}/java8/io/UncheckedIOException.java"
sed -Ei \
-e "s/^(\s*package\s+)java(\.io\s*;\s*)$/\1java8\2/" \
-e '/^\s*import\s+java\.util\.Objects\s*;\s*$/a\import java.io.*;' \
"${LIBRARY_JAVA_SOURCE_ROOT}/java8/io/UncheckedIOException.java"
cat >"${LIBRARY_JAVA_SOURCE_ROOT}/java8/io/BufferedReaders.java" <<EOF
/*
 * Copyright (C) 2014 The Android Open Source Project
 * Copyright (c) 1996, 2013, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.  Oracle designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the LICENSE file that accompanied this code.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have any
 * questions.
 */

package java8.io;

import java.io.*;
import java.util.Iterator;
import java.util.NoSuchElementException;
import java9.util.Spliterator;
import java9.util.Spliterators;
import java9.util.stream.Stream;
import java9.util.stream.StreamSupport;

public class BufferedReaders {

    private BufferedReaders() {}

    /**
     * Returns a {@code Stream}, the elements of which are lines read from
     * this {@code BufferedReader}.  The {@link Stream} is lazily populated,
     * i.e., read only occurs during the
     * <a href="../util/stream/package-summary.html#StreamOps">terminal
     * stream operation</a>.
     *
     * <p> The reader must not be operated on during the execution of the
     * terminal stream operation. Otherwise, the result of the terminal stream
     * operation is undefined.
     *
     * <p> After execution of the terminal stream operation there are no
     * guarantees that the reader will be at a specific position from which to
     * read the next character or line.
     *
     * <p> If an {@link IOException} is thrown when accessing the underlying
     * {@code BufferedReader}, it is wrapped in an {@link
     * UncheckedIOException} which will be thrown from the {@code Stream}
     * method that caused the read to take place. This method will return a
     * Stream if invoked on a BufferedReader that is closed. Any operation on
     * that stream that requires reading from the BufferedReader after it is
     * closed, will cause an UncheckedIOException to be thrown.
     *
     * @return a {@code Stream<String>} providing the lines of text
     *         described by this {@code BufferedReader}
     *
     * @since 1.8
     */
    public static Stream<String> lines(BufferedReader bufferedReader) {
        Iterator<String> iter = new Iterator<String>() {
            String nextLine = null;

            @Override
            public boolean hasNext() {
                if (nextLine != null) {
                    return true;
                } else {
                    try {
                        nextLine = bufferedReader.readLine();
                        return (nextLine != null);
                    } catch (IOException e) {
                        throw new UncheckedIOException(e);
                    }
                }
            }

            @Override
            public String next() {
                if (nextLine != null || hasNext()) {
                    String line = nextLine;
                    nextLine = null;
                    return line;
                } else {
                    throw new NoSuchElementException();
                }
            }
        };
        return StreamSupport.stream(Spliterators.spliteratorUnknownSize(
                iter, Spliterator.ORDERED | Spliterator.NONNULL), false);
    }
}
EOF
find "${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file" -iname '*.java' -type f -print0 | xargs -0 sed -Ei \
-e 's/\bjava(\.io\.UncheckedIOException)\b/java8\1/g' \
-e "s/\b([A-Za-z][A-Za-z0-9_]*)\.lines\(\)/java8.io.BufferedReaders.lines(\1)/g"

git apply <<EOF
diff --git a/library/src/main/java/java8/nio/file/DirectoryIteratorException.java b/library/src/main/java/java8/nio/file/DirectoryIteratorException.java
index 7356794..fd0d53d 100644
--- a/library/src/main/java/java8/nio/file/DirectoryIteratorException.java
+++ b/library/src/main/java/java8/nio/file/DirectoryIteratorException.java
@@ -56,7 +56,9 @@ public final class DirectoryIteratorException
      *          if the cause is {@code null}
      */
     public DirectoryIteratorException(IOException cause) {
-        super(org.threeten.bp.jdk8.Jdk8Methods.requireNonNull(cause));
+        super(org.threeten.bp.jdk8.Jdk8Methods.requireNonNull(cause).toString());
+
+        initCause(cause);
     }
 
     /**
diff --git a/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/FileSystems.java b/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/FileSystems.java
index 432f013..cfdaacb 100644
--- a/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/FileSystems.java
+++ b/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/FileSystems.java
@@ -105,31 +105,7 @@ public final class FileSystems {
 
         // returns default provider
         private static FileSystemProvider getDefaultProvider() {
-            FileSystemProvider provider = sun.nio.fs.DefaultFileSystemProvider.create();
-
-            // if the property java8.nio.file.spi.DefaultFileSystemProvider is
-            // set then its value is the name of the default provider (or a list)
-            String propValue = System
-                .getProperty("java8.nio.file.spi.DefaultFileSystemProvider");
-            if (propValue != null) {
-                for (String cn: propValue.split(",")) {
-                    try {
-                        Class<?> c = Class
-                            .forName(cn, true, ClassLoader.getSystemClassLoader());
-                        Constructor<?> ctor = c
-                            .getDeclaredConstructor(FileSystemProvider.class);
-                        provider = (FileSystemProvider)ctor.newInstance(provider);
-
-                        // must be "file"
-                        if (!provider.getScheme().equals("file"))
-                            throw new Error("Default provider must use scheme 'file'");
-
-                    } catch (Exception x) {
-                        throw new Error(x);
-                    }
-                }
-            }
-            return provider;
+            return FileSystemProvider.defaultProvider();
         }
     }
 
diff --git a/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/FileTreeWalker.java b/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/FileTreeWalker.java
index 1897e18..82d8a45 100644
--- a/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/FileTreeWalker.java
+++ b/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/FileTreeWalker.java
@@ -200,17 +200,6 @@ class FileTreeWalker implements Closeable {
     private BasicFileAttributes getAttributes(Path file, boolean canUseCached)
         throws IOException
     {
-        // if attributes are cached then use them if possible
-        if (canUseCached &&
-            (file instanceof BasicFileAttributesHolder) &&
-            (System.getSecurityManager() == null))
-        {
-            BasicFileAttributes cached = ((BasicFileAttributesHolder)file).get();
-            if (cached != null && (!followLinks || !cached.isSymbolicLink())) {
-                return cached;
-            }
-        }
-
         // attempt to get attributes of file. If fails and we are following
         // links then a link target might not exist so get attributes of link
         BasicFileAttributes attrs;
diff --git a/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/Files.java b/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/Files.java
index cc80aa7..4695b94 100644
--- a/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/Files.java
+++ b/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/Files.java
@@ -1531,35 +1531,12 @@ public final class Files {
         return provider(path).isHidden(path);
     }
 
-    // lazy loading of default and installed file type detectors
-    private static class FileTypeDetectors{
-        static final FileTypeDetector defaultFileTypeDetector =
-            createDefaultFileTypeDetector();
-        static final List<FileTypeDetector> installeDetectors =
-            loadInstalledDetectors();
-
-        // creates the default file type detector
-        private static FileTypeDetector createDefaultFileTypeDetector() {
-            return AccessController
-                .doPrivileged(new PrivilegedAction<FileTypeDetector>() {
-                    @Override public FileTypeDetector run() {
-                        return sun.nio.fs.DefaultFileTypeDetector.create();
-                }});
-        }
+    private static final List<FileTypeDetector> installedDetectors = new ArrayList<>();
+    private static final Object installedDetectorsLock = new Object();
 
-        // loads all installed file type detectors
-        private static List<FileTypeDetector> loadInstalledDetectors() {
-            return AccessController
-                .doPrivileged(new PrivilegedAction<List<FileTypeDetector>>() {
-                    @Override public List<FileTypeDetector> run() {
-                        List<FileTypeDetector> list = new ArrayList<>();
-                        ServiceLoader<FileTypeDetector> loader = ServiceLoader
-                            .load(FileTypeDetector.class, ClassLoader.getSystemClassLoader());
-                        for (FileTypeDetector detector: loader) {
-                            list.add(detector);
-                        }
-                        return list;
-                }});
+    public static void installFileTypeDetector(FileTypeDetector detector) {
+        synchronized (installedDetectorsLock) {
+            installedDetectors.add(detector);
         }
     }
 
@@ -1614,14 +1591,14 @@ public final class Files {
         throws IOException
     {
         // try installed file type detectors
-        for (FileTypeDetector detector: FileTypeDetectors.installeDetectors) {
+        for (FileTypeDetector detector: installedDetectors) {
             String result = detector.probeContentType(path);
             if (result != null)
                 return result;
         }
 
         // fallback to default
-        return FileTypeDetectors.defaultFileTypeDetector.probeContentType(path);
+        return null;
     }
 
     // -- File Attributes --
diff --git a/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/TempFileHelper.java b/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/TempFileHelper.java
index 5ea48f2..cfb83a7 100644
--- a/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/TempFileHelper.java
+++ b/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/TempFileHelper.java
@@ -46,7 +46,7 @@ class TempFileHelper {
 
     // temporary directory location
     private static final Path tmpdir =
-        Paths.get(doPrivileged(new GetPropertyAction("java.io.tmpdir")));
+        Paths.get(System.getProperty("java.io.tmpdir", "."));
 
     private static final boolean isPosix =
         FileSystems.getDefault().supportedFileAttributeViews().contains("posix");
diff --git a/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/spi/FileSystemProvider.java b/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/spi/FileSystemProvider.java
index 9fc2ff4..476aab8 100644
--- a/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/spi/FileSystemProvider.java
+++ b/${LIBRARY_JAVA_SOURCE_ROOT}/java8/nio/file/spi/FileSystemProvider.java
@@ -81,10 +81,7 @@ public abstract class FileSystemProvider {
     private static final Object lock = new Object();
 
     // installed providers
-    private static volatile List<FileSystemProvider> installedProviders;
-
-    // used to avoid recursive loading of instaled providers
-    private static boolean loadingProviders  = false;
+    private static volatile List<FileSystemProvider> installedProviders = new ArrayList<>();
 
     private static Void checkPermission() {
         SecurityManager sm = System.getSecurityManager();
@@ -110,32 +107,40 @@ public abstract class FileSystemProvider {
         this(checkPermission());
     }
 
-    // loads all installed providers
-    private static List<FileSystemProvider> loadInstalledProviders() {
-        List<FileSystemProvider> list = new ArrayList<FileSystemProvider>();
+    public static void installDefaultProvider(FileSystemProvider provider) {
+        if (!provider.getScheme().equals("file")) {
+            throw new Error("Default provider must use scheme 'file'");
+        }
+        synchronized (lock) {
+            if (!installedProviders.isEmpty()) {
+                throw new Error("A provider has already been installed");
+            }
+            installedProviders.add(provider);
+        }
+    }
 
-        ServiceLoader<FileSystemProvider> sl = ServiceLoader
-            .load(FileSystemProvider.class, ClassLoader.getSystemClassLoader());
+    public static FileSystemProvider defaultProvider() {
+        synchronized (lock) {
+            if (installedProviders.isEmpty()) {
+                throw new Error("Must initialize with FileSystemProvider.installDefaultProvider()");
+            }
+            return installedProviders.get(0);
+        }
+    }
 
-        // ServiceConfigurationError may be throw here
-        for (FileSystemProvider provider: sl) {
+    public static void installProvider(FileSystemProvider provider) {
+        synchronized (lock) {
+            if (installedProviders.isEmpty()) {
+                throw new Error("Must initialize with FileSystemProvider.installDefaultProvider()");
+            }
             String scheme = provider.getScheme();
-
-            // add to list if the provider is not "file" and isn't a duplicate
-            if (!scheme.equalsIgnoreCase("file")) {
-                boolean found = false;
-                for (FileSystemProvider p: list) {
-                    if (p.getScheme().equalsIgnoreCase(scheme)) {
-                        found = true;
-                        break;
-                    }
-                }
-                if (!found) {
-                    list.add(provider);
+            for (FileSystemProvider p : installedProviders) {
+                if (p.getScheme().equalsIgnoreCase(scheme)) {
+                    return;
                 }
             }
+            installedProviders.add(provider);
         }
-        return list;
     }
 
     /**
@@ -153,32 +158,9 @@ public abstract class FileSystemProvider {
      *          When an error occurs while loading a service provider
      */
     public static List<FileSystemProvider> installedProviders() {
-        if (installedProviders == null) {
-            // ensure default provider is initialized
-            FileSystemProvider defaultProvider = FileSystems.getDefault().provider();
-
-            synchronized (lock) {
-                if (installedProviders == null) {
-                    if (loadingProviders) {
-                        throw new Error("Circular loading of installed providers detected");
-                    }
-                    loadingProviders = true;
-
-                    List<FileSystemProvider> list = AccessController
-                        .doPrivileged(new PrivilegedAction<List<FileSystemProvider>>() {
-                            @Override
-                            public List<FileSystemProvider> run() {
-                                return loadInstalledProviders();
-                        }});
-
-                    // insert the default provider at the start of the list
-                    list.add(0, defaultProvider);
-
-                    installedProviders = Collections.unmodifiableList(list);
-                }
-            }
+        synchronized (lock) {
+            return new ArrayList<>(installedProviders);
         }
-        return installedProviders;
     }
 
     /**
EOF
