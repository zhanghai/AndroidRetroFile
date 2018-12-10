# AndroidRetroFile

A backport of java.nio.file API (JSR 203) for Android.

## Integration

dependencies {
    implementation 'me.zhanghai.android.retrofile:library:1.0.0'
}

## Usage

This backported API is under `java8.nio.file`.

No default `FileSystemProvider` implementation is bundled within this library, and the API is modified to allow dynamic install of providers.

Before using the API, you need to set a default provider implementation with `FileSystemProvider.installDefaultProvider()`. More providers can be installed with `FileSystemProvider.installProvider()` at any time.

Similarly, there is no default `FileTypeDetector` implementation, and you can install one with `Files.installFileTypeDetector()` at any time.

## License

[GNU General Public License, version 2, with the Classpath Exception](https://openjdk.java.net/legal/gplv2+ce.html)
