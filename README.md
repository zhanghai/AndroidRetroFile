# AndroidRetroFile

A backport of java.nio.file API (JSR 203) for Android.

## Integration

```gradle
dependencies {
    implementation 'me.zhanghai.android.retrofile:library:1.2.0'
}
```

## Usage

The backported API is under `java8.nio.file`.

No default [`FileSystemProvider`](blob/master/library/src/main/java/java8/nio/file/spi/FileSystemProvider.java) implementation is bundled within this library, and the API is modified to allow dynamic install of providers.

Before using the API, you need to set a default provider implementation with `FileSystemProvider.installDefaultProvider()`. More providers can be installed with `FileSystemProvider.installProvider()` at any time.

Similarly, there is no default [`FileTypeDetector`](blob/master/library/src/main/java/java8/nio/file/spi/FileTypeDetector.java) implementation, and you can install one with `Files.installFileTypeDetector()` at any time.

This backport uses the [default version](https://developer.android.com/studio/write/java11-default-support-table) of [Java 8+ API desugaring support](https://developer.android.com/studio/write/java8-support) for `java.util.stream` and `java.time`.

## License

[GNU General Public License, version 2, with the Classpath Exception](LICENSE)
