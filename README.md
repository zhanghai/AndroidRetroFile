# AndroidRetroFile

A backport of java.nio.file API (JSR 203) for Android.

## Integration

```gradle
dependencies {
    implementation 'me.zhanghai.android.retrofile:library:1.1.1'
}
```

## Usage

The backported API is under `java8.nio.file`.

No default [`FileSystemProvider`](blob/master/library/src/main/java/java8/nio/file/spi/FileSystemProvider.java) implementation is bundled within this library, and the API is modified to allow dynamic install of providers.

Before using the API, you need to set a default provider implementation with `FileSystemProvider.installDefaultProvider()`. More providers can be installed with `FileSystemProvider.installProvider()` at any time.

Similarly, there is no default [`FileTypeDetector`](blob/master/library/src/main/java/java8/nio/file/spi/FileTypeDetector.java) implementation, and you can install one with `Files.installFileTypeDetector()` at any time.

This backport uses [android-retrostreams](https://github.com/retrostreams/android-retrostreams) for `java.util.stream` and [ThreeTenABP](https://github.com/JakeWharton/ThreeTenABP) for `java.time`, and they are exposed as an API dependency of this library.

## License

[GNU General Public License, version 2, with the Classpath Exception](LICENSE)
