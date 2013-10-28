package server.auth
{
    import flash.utils.ByteArray;

    public class Crypt
    {

        private static const CRYPT_KEY: String = 'T2%o9^24C2r14}:p63zU';

        private var keyLen: uint = CRYPT_KEY.length;
        private var sendI: int;
        private var sendJ: int;
        private var recvI: int;
        private var recvJ: int;

        public function Crypt()
        {
            sendI = 0;
            sendJ = 0;
            recvI = 0;
            recvJ = 0;
        }

        public function decryptRecv(data: ByteArray, size: uint): void
        {
            var x: uint;

            for (var i: int = 0; i < size; i++)
            {
                recvI %= keyLen;
                x = (data[i] - recvJ) ^ CRYPT_KEY.charCodeAt(recvI);
                recvI++;
                recvJ = data[i];
                data[i] = x;
            }
        }


        public function encryptSend(data: ByteArray, size: uint): void
        {
            for (var i: int = 0; i < size; i++)
            {
                sendI %= keyLen;
                data[i] = sendJ = (data[i] ^ CRYPT_KEY.charCodeAt(sendI)) + sendJ;
                sendI++;
            }
        }
    }
}
