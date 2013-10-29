/*
 nochump.util.zip.CRC32
 Copyright (C) 2007 David Chang (dchang@nochump.com)

 This file is part of nochump.util.zip.

 nochump.util.zip is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 nochump.util.zip is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */
package server
{

    import flash.utils.ByteArray;

    /**
     * Computes CRC32 data checksum of a data stream.
     * The actual CRC32 algorithm is described in RFC 1952
     * (GZIP file format specification version 4.3).
     *
     * @author David Chang
     * @date January 2, 2007.
     */
    public class CRC32
    {

        /** The crc data checksum so far. */
        private var crc: uint;

        /** The fast CRC table. Computed once when the CRC32 class is loaded. */
        private static var crcTable: Array = makeCrcTable();

        private static const CRC_POLY: uint = 0x82f63b78;
        private static const CRC_INIT: uint = 0xffffffff;

        /** Make the table for a fast CRC. */
        private static function makeCrcTable(): Array
        {
            var crcTable: Array = new Array(256);
            for (var n: int = 0; n < 256; n++)
            {
                var c: uint = n;
                for (var k: int = 8; --k >= 0;)
                {
                    if ((c & 1) != 0) c = CRC_POLY ^ (c >>> 1);
                    else c = c >>> 1;
                }
                crcTable[n] = c;
            }
            return crcTable;
        }

        /**
         * Returns the CRC32 data checksum computed so far.
         */
        public function getValue(): uint
        {
            return crc & CRC_INIT;
        }

        /**
         * Resets the CRC32 data checksum as if no update was ever called.
         */
        public function reset(): void
        {
            crc = 0;
        }

        /**
         * Adds the complete byte array to the data checksum.
         *
         * @param buf the buffer which contains the data
         */
        public function update(buf: ByteArray): void
        {
            var off: uint = 0;
            var len: uint = buf.length;
            var c: uint = ~crc;
            while (--len >= 0)
                c = crcTable[(c ^ buf[off++]) & 0xff] ^ (c >>> 8);
            crc = ~c;
        }

        /**
         * reset previous CRC and computes new CRC from provided bytearray
         * @param buf
         * @return
         */
        public function computeCRC32(buf: ByteArray): uint
        {
            reset();
            update(buf);
            return getValue();
        }

    }

}