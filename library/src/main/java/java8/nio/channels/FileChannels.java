/*
 * Copyright (c) 2018 Hai Zhang <dreaming.in.code.zh@gmail.com>
 * All Rights Reserved.
 */

package java8.nio.channels;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileLock;
import java.nio.channels.ReadableByteChannel;
import java.nio.channels.WritableByteChannel;

public class FileChannels {

    private FileChannels() {}

    public static FileChannel from(java.nio.channels.FileChannel fileChannel) {
        return new DelegateFileChannel(fileChannel);
    }

    private static class DelegateFileChannel extends FileChannel {

        private final java.nio.channels.FileChannel mFileChannel;

        public DelegateFileChannel(java.nio.channels.FileChannel fileChannel) {
            mFileChannel = fileChannel;
        }

        @Override
        public int read(ByteBuffer dst) throws IOException {
            return mFileChannel.read(dst);
        }

        @Override
        public long read(ByteBuffer[] dsts, int offset, int length) throws IOException {
            return mFileChannel.read(dsts, offset, length);
        }

        @Override
        public int write(ByteBuffer src) throws IOException {
            return mFileChannel.write(src);
        }

        @Override
        public long write(ByteBuffer[] srcs, int offset, int length) throws IOException {
            return mFileChannel.write(srcs, offset, length);
        }

        @Override
        public long position() throws IOException {
            return mFileChannel.position();
        }

        @Override
        public DelegateFileChannel position(long newPosition) throws IOException {
            mFileChannel.position(newPosition);
            return this;
        }

        @Override
        public long size() throws IOException {
            return mFileChannel.size();
        }

        @Override
        public DelegateFileChannel truncate(long size) throws IOException {
            mFileChannel.truncate(size);
            return this;
        }

        public void force(boolean metaData) throws IOException {
            mFileChannel.force(metaData);
        }

        public long transferTo(long position, long count, WritableByteChannel target)
                throws IOException {
            return mFileChannel.transferTo(position, count, target);
        }

        public long transferFrom(ReadableByteChannel src, long position, long count)
                throws IOException {
            return mFileChannel.transferFrom(src, position, count);
        }

        public int read(ByteBuffer dst, long position) throws IOException {
            return mFileChannel.read(dst, position);
        }

        public int write(ByteBuffer src, long position) throws IOException {
            return mFileChannel.write(src, position);
        }

        public MappedByteBuffer map(MapMode mode, long position, long size)
                throws IOException {
            return mFileChannel.map(mode, position, size);
        }

        public FileLock lock(long position, long size, boolean shared) throws IOException {
            return mFileChannel.lock(position, size, shared);
        }

        public FileLock tryLock(long position, long size, boolean shared) throws IOException {
            return mFileChannel.tryLock(position, size, shared);
        }

        @Override
        protected void implCloseChannel() throws IOException {
            mFileChannel.close();
        }
    }
}
