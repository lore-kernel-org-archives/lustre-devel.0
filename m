From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:07 -0400
Subject: [lustre-devel] [PATCH 11/20] lustre: sec: documentation for
 client-side encryption
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Add several documents about client-side encryption under
Documentation/client_side_encryption:
- threat_model.txt is the description of the threat model for Lustre
  client-side encryption;
- key_hierarchy.txt is the description of the key hierarchy for Lustre
  client-side encryption;
- modes_usage.txt is the description of the encryption modes and usage
  for Lustre client-side encryption;
- access_semantics.txt is the description of the access semantics for
  Lustre client-side encryption.

As we rely on kernel's fscrypt library for this feature, fscrypt's
concepts are largely valid. These documents are inspired by fscrypt
documentation in the Linux kernel tree, see
Documentation/filesystems/fscrypt.rst

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: f2bf564e691ea ("LU-12275 sec: documentation for client-side encryption")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/38759
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../client_side_encryption/access_semantics.txt    | 128 +++++++++++++++++
 .../client_side_encryption/key_hierarchy.txt       | 112 +++++++++++++++
 .../lustre/client_side_encryption/modes_usage.txt  |  97 +++++++++++++
 .../lustre/client_side_encryption/threat_model.txt | 159 +++++++++++++++++++++
 4 files changed, 496 insertions(+)
 create mode 100644 Documentation/lustre/client_side_encryption/access_semantics.txt
 create mode 100644 Documentation/lustre/client_side_encryption/key_hierarchy.txt
 create mode 100644 Documentation/lustre/client_side_encryption/modes_usage.txt
 create mode 100644 Documentation/lustre/client_side_encryption/threat_model.txt

diff --git a/Documentation/lustre/client_side_encryption/access_semantics.txt b/Documentation/lustre/client_side_encryption/access_semantics.txt
new file mode 100644
index 0000000..fe2c28d
--- /dev/null
+++ b/Documentation/lustre/client_side_encryption/access_semantics.txt
@@ -0,0 +1,128 @@
+===============================================
+Lustre client-level encryption access semantics
+===============================================
+
+Lustre client-level encryption relies on kernel's fscrypt, and more
+precisely on v2 encryption policies.
+fscrypt is a library which filesystems can hook into to support
+transparent encryption of files and directories.
+
+As a consequence, the access semantics described here, extracted from
+fscrypt's doc, apply to Lustre client-level encryption.
+
+Ref:
+https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/filesystems/fscrypt.rst
+
+Access
+======
+
+Only Lustre clients need access to encryption master keys. Keys are
+added to the filesystem-level encryption keyring on the Lustre client.
+
+With the key
+------------
+
+With the encryption key, encrypted regular files, directories, and
+symlinks behave very similarly to their unencrypted counterparts ---
+after all, the encryption is intended to be transparent.  However,
+astute users may notice some differences in behavior:
+
+- Unencrypted files, or files encrypted with a different encryption
+  policy (i.e. different key, modes, or flags), cannot be renamed or
+  linked into an encrypted directory; see `Encryption policy
+  enforcement`_.  Attempts to do so will fail with EXDEV.  However,
+  encrypted files can be renamed within an encrypted directory, or
+  into an unencrypted directory.
+
+  Note: "moving" an unencrypted file into an encrypted directory, e.g.
+  with the `mv` program, is implemented in userspace by a copy
+  followed by a delete.  Be aware that the original unencrypted data
+  may remain recoverable from free space on the disk; prefer to keep
+  all files encrypted from the very beginning.  The `shred` program
+  may be used to overwrite the source files but isn't guaranteed to be
+  effective on all filesystems and storage devices.
+
+- Direct I/O is not supported on encrypted files.  Attempts to use
+  direct I/O on such files will fall back to buffered I/O.
+
+- The fallocate operations FALLOC_FL_COLLAPSE_RANGE,
+  FALLOC_FL_INSERT_RANGE, and FALLOC_FL_ZERO_RANGE are not supported
+  on encrypted files and will fail with EOPNOTSUPP.
+
+- DAX (Direct Access) is not supported on encrypted files.
+
+- The st_size of an encrypted symlink will not necessarily give the
+  length of the symlink target as required by POSIX.  It will actually
+  give the length of the ciphertext, which will be slightly longer
+  than the plaintext due to NUL-padding and an extra 2-byte overhead.
+
+- The maximum length of an encrypted symlink is 2 bytes shorter than
+  the maximum length of an unencrypted symlink.  For example, on an
+  EXT4 filesystem with a 4K block size, unencrypted symlinks can be up
+  to 4095 bytes long, while encrypted symlinks can only be up to 4093
+  bytes long (both lengths excluding the terminating null).
+
+Note that mmap *is* supported.  This is possible because the pagecache
+for an encrypted file contains the plaintext, not the ciphertext.
+
+Without the key
+---------------
+
+Some filesystem operations may be performed on encrypted regular
+files, directories, and symlinks even before their encryption key has
+been added, or after their encryption key has been removed:
+
+- File metadata may be read, e.g. using stat().
+
+- Directories may be listed, in which case the filenames will be
+  listed in an encoded form derived from their ciphertext.  The
+  algorithm is subject to change, but it is guaranteed that the
+  presented filenames will be no longer than NAME_MAX bytes, will not
+  contain the ``/`` or ``\0`` characters, and will uniquely identify
+  directory entries.
+
+  The ``.`` and ``..`` directory entries are special.  They are always
+  present and are not encrypted or encoded.
+
+- Files may be deleted.  That is, nondirectory files may be deleted
+  with unlink() as usual, and empty directories may be deleted with
+  rmdir() as usual.  Therefore, ``rm`` and ``rm -r`` will work as
+  expected.
+
+- Symlink targets may be read and followed, but they will be presented
+  in encrypted form, similar to filenames in directories.  Hence, they
+  are unlikely to point to anywhere useful.
+
+Without the key, regular files cannot be opened or truncated.
+Attempts to do so will fail with ENOKEY.  This implies that any
+regular file operations that require a file descriptor, such as
+read(), write(), mmap(), fallocate(), and ioctl(), are also forbidden.
+
+Also without the key, files of any type (including directories) cannot
+be created or linked into an encrypted directory, nor can a name in an
+encrypted directory be the source or target of a rename, nor can an
+O_TMPFILE temporary file be created in an encrypted directory.  All
+such operations will fail with ENOKEY.
+
+It is not currently possible to backup and restore encrypted files
+without the encryption key.  This would require special APIs which
+have not yet been implemented.
+
+Encryption policy enforcement
+=============================
+
+After an encryption policy has been set on a directory, all regular
+files, directories, and symbolic links created in that directory
+(recursively) will inherit that encryption policy.  Special files ---
+that is, named pipes, device nodes, and UNIX domain sockets --- will
+not be encrypted.
+
+Except for those special files, it is forbidden to have unencrypted
+files, or files encrypted with a different encryption policy, in an
+encrypted directory tree.  Attempts to link or rename such a file into
+an encrypted directory will fail with EXDEV.  This is also enforced
+during ->lookup() to provide limited protection against offline
+attacks that try to disable or downgrade encryption in known locations
+where applications may later write sensitive data.  It is recommended
+that systems implementing a form of "verified boot" take advantage of
+this by validating all top-level encryption policies prior to access.
diff --git a/Documentation/lustre/client_side_encryption/key_hierarchy.txt b/Documentation/lustre/client_side_encryption/key_hierarchy.txt
new file mode 100644
index 0000000..d96e189
--- /dev/null
+++ b/Documentation/lustre/client_side_encryption/key_hierarchy.txt
@@ -0,0 +1,112 @@
+============================================
+Lustre client-level encryption key hierarchy
+============================================
+
+Lustre client-level encryption relies on kernel's fscrypt, and more
+precisely on v2 encryption policies.
+fscrypt is a library which filesystems can hook into to support
+transparent encryption of files and directories.
+
+As a consequence, the following key hierarchy description, extracted
+from fscrypt's, is directly applicable to Lustre client-level encryption.
+
+Ref:
+https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/filesystems/fscrypt.rst
+
+Master Keys
+-----------
+
+Each encrypted directory tree is protected by a *master key*.  Master
+keys can be up to 64 bytes long, and must be at least as long as the
+greater of the key length needed by the contents and filenames
+encryption modes being used.  For example, if AES-256-XTS is used for
+contents encryption, the master key must be 64 bytes (512 bits).  Note
+that the XTS mode is defined to require a key twice as long as that
+required by the underlying block cipher.
+
+To "unlock" an encrypted directory tree, userspace must provide the
+appropriate master key.  There can be any number of master keys, each
+of which protects any number of directory trees on any number of
+filesystems.
+
+Master keys should be pseudorandom, i.e. indistinguishable from random
+bytestrings of the same length.  This implies that users **must not**
+directly use a password as a master key, zero-pad a shorter key, or
+repeat a shorter key.  Instead, users should generate master keys
+either using a cryptographically secure random number generator, or by
+using a KDF (Key Derivation Function).  Note that whenever a KDF is
+used to "stretch" a lower-entropy secret such as a passphrase, it is
+critical that a KDF designed for this purpose be used, such as scrypt,
+PBKDF2, or Argon2.
+
+Key derivation function
+-----------------------
+
+With one exception, fscrypt never uses the master key(s) for
+encryption directly.  Instead, they are only used as input to a KDF
+(Key Derivation Function) to derive the actual keys.
+
+For v2 encryption policies, the KDF is HKDF-SHA512. The master key is
+passed as the "input keying material", no salt is used, and a distinct
+"application-specific information string" is used for each distinct
+key to be derived.  For example, when a per-file encryption key is
+derived, the application-specific information string is the file's
+nonce prefixed with "fscrypt\0" and a context byte.  Different context
+bytes are used for other types of derived keys.
+
+HKDF-SHA512 is preferred KDF because HKDF is more flexible, is
+nonreversible, and evenly distributes entropy from the master key.
+HKDF is also standardized and widely used by other software.
+
+Per-file keys
+-------------
+
+Since each master key can protect many files, it is necessary to
+"tweak" the encryption of each file so that the same plaintext in two
+files doesn't map to the same ciphertext, or vice versa.  In most
+cases, fscrypt does this by deriving per-file keys.  When a new
+encrypted inode (regular file, directory, or symlink) is created,
+fscrypt randomly generates a 16-byte nonce and stores it in the
+inode's encryption xattr.  Then, it uses a KDF (as described in `Key
+derivation function`_) to derive the file's key from the master key
+and nonce.
+
+Key derivation was chosen over key wrapping because wrapped keys would
+require larger xattrs which would be less likely to fit in-line in the
+filesystem's inode table, and there didn't appear to be any
+significant advantages to key wrapping.  In particular, currently
+there is no requirement to support unlocking a file with multiple
+alternative master keys or to support rotating master keys.  Instead,
+the master keys may be wrapped in userspace, e.g. as is done by the
+`fscrypt <https://github.com/google/fscrypt>`_ tool.
+
+Including the inode number in the IVs was considered.  However, it was
+rejected as it would have prevented ext4 filesystems from being
+resized, and by itself still wouldn't have been sufficient to prevent
+the same key from being directly reused for both XTS and CTS-CBC.
+
+DIRECT_KEY and per-mode keys
+----------------------------
+
+The Adiantum encryption mode is suitable for both contents and
+filenames encryption, and it accepts long IVs --- long enough to hold
+both an 8-byte logical block number and a 16-byte per-file nonce.
+Also, the overhead of each Adiantum key is greater than that of an
+AES-256-XTS key.
+
+Therefore, to improve performance and save memory, for Adiantum a
+"direct key" configuration is supported.  When the user has enabled
+this by setting FSCRYPT_POLICY_FLAG_DIRECT_KEY in the fscrypt policy,
+per-file keys are not used.  Instead, whenever any data (contents or
+filenames) is encrypted, the file's 16-byte nonce is included in the
+IV.  Moreover, for v2 encryption policies, the encryption is done with
+a per-mode key derived using the KDF.  Users may use the same master
+key for other v2 encryption policies.
+
+Key identifiers
+---------------
+
+For master keys used for v2 encryption policies, a unique 16-byte "key
+identifier" is also derived using the KDF.  This value is stored in
+the clear, since it is needed to reliably identify the key itself.
+
diff --git a/Documentation/lustre/client_side_encryption/modes_usage.txt b/Documentation/lustre/client_side_encryption/modes_usage.txt
new file mode 100644
index 0000000..4ad8cf5
--- /dev/null
+++ b/Documentation/lustre/client_side_encryption/modes_usage.txt
@@ -0,0 +1,97 @@
+==============================================
+Lustre client-level encryption modes and usage
+==============================================
+
+Lustre client-level encryption relies on kernel's fscrypt, and more
+precisely on v2 encryption policies.
+fscrypt is a library which filesystems can hook into to support
+transparent encryption of files and directories.
+
+As a consequence, the encryption modes and usage described here,
+extracted from fscrypt's doc, apply to Lustre client-level encryption.
+
+Ref:
+https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/filesystems/fscrypt.rst
+
+Encryption modes
+----------------
+
+fscrypt allows one encryption mode to be specified for file contents
+and one encryption mode to be specified for filenames.  Different
+directory trees are permitted to use different encryption modes.
+Currently, the following pairs of encryption modes are supported:
+
+- AES-256-XTS for contents and AES-256-CTS-CBC for filenames
+- AES-128-CBC for contents and AES-128-CTS-CBC for filenames
+- Adiantum for both contents and filenames
+
+If unsure, you should use the (AES-256-XTS, AES-256-CTS-CBC) pair.
+
+AES-128-CBC was added only for low-powered embedded devices with
+crypto accelerators such as CAAM or CESA that do not support XTS.
+
+Adiantum is a (primarily) stream cipher-based mode that is fast even
+on CPUs without dedicated crypto instructions.  It's also a true
+wide-block mode, unlike XTS.  It can also eliminate the need to derive
+per-file keys.  However, it depends on the security of two primitives,
+XChaCha12 and AES-256, rather than just one.  See the paper
+"Adiantum: length-preserving encryption for entry-level processors"
+(https://eprint.iacr.org/2018/720.pdf) for more details.  To use
+Adiantum, CONFIG_CRYPTO_ADIANTUM must be enabled.  Also, fast
+implementations of ChaCha and NHPoly1305 should be enabled, e.g.
+CONFIG_CRYPTO_CHACHA20_NEON and CONFIG_CRYPTO_NHPOLY1305_NEON for ARM.
+
+Contents encryption
+-------------------
+
+For file contents, each filesystem block is encrypted independently.
+Currently, only the case where the filesystem block size is equal to
+the system's page size (usually 4096 bytes) is supported.
+
+Each block's IV is set to the logical block number within the file as
+a little endian number, except that:
+
+- With CBC mode encryption, ESSIV is also used.  Specifically, each IV
+  is encrypted with AES-256 where the AES-256 key is the SHA-256 hash
+  of the file's data encryption key.
+
+- In the "direct key" configuration (FSCRYPT_POLICY_FLAG_DIRECT_KEY
+  set in the fscrypt_policy), the file's nonce is also appended to the
+  IV.  Currently this is only allowed with the Adiantum encryption
+  mode.
+
+Filenames encryption
+--------------------
+
+For filenames, each full filename is encrypted at once.  Because of
+the requirements to retain support for efficient directory lookups and
+filenames of up to 255 bytes, the same IV is used for every filename
+in a directory.
+
+However, each encrypted directory still uses a unique key; or
+alternatively (for the "direct key" configuration) has the file's
+nonce included in the IVs.  Thus, IV reuse is limited to within a
+single directory.
+
+With CTS-CBC, the IV reuse means that when the plaintext filenames
+share a common prefix at least as long as the cipher block size (16
+bytes for AES), the corresponding encrypted filenames will also share
+a common prefix.  This is undesirable.  Adiantum does not have this
+weakness, as it is a wide-block encryption mode.
+
+All supported filenames encryption modes accept any plaintext length
+>= 16 bytes; cipher block alignment is not required.  However,
+filenames shorter than 16 bytes are NUL-padded to 16 bytes before
+being encrypted.  In addition, to reduce leakage of filename lengths
+via their ciphertexts, all filenames are NUL-padded to the next 4, 8,
+16, or 32-byte boundary (configurable).  32 is recommended since this
+provides the best confidentiality, at the cost of making directory
+entries consume slightly more space.  Note that since NUL (``\0``) is
+not otherwise a valid character in filenames, the padding will never
+produce duplicate plaintexts.
+
+Symbolic link targets are considered a type of filename and are
+encrypted in the same way as filenames in directory entries, except
+that IV reuse is not a problem as each symlink has its own inode.
+
+
diff --git a/Documentation/lustre/client_side_encryption/threat_model.txt b/Documentation/lustre/client_side_encryption/threat_model.txt
new file mode 100644
index 0000000..f9153a2
--- /dev/null
+++ b/Documentation/lustre/client_side_encryption/threat_model.txt
@@ -0,0 +1,159 @@
+===========================================
+Lustre client-level encryption threat model
+===========================================
+
+Lustre client-level encryption relies on kernel's fscrypt, and more
+precisely on v2 encryption policies.
+fscrypt is a library which filesystems can hook into to support
+transparent encryption of files and directories.
+
+As a consequence, the following threat model, extracted from
+fscrypt's and adapted, is applicable to Lustre client-level
+encryption.
+
+Ref:
+https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/filesystems/fscrypt.rst
+
+Offline attacks
+---------------
+
+Provided that userspace chooses a strong encryption key, fscrypt
+protects the confidentiality of file contents and filenames in the
+event of a single point-in-time permanent offline compromise of the
+block device content.  fscrypt does not protect the confidentiality of
+non-filename metadata, e.g. file sizes, file permissions, file
+timestamps, and extended attributes.  Also, the existence and location
+of holes (unallocated blocks which logically contain all zeroes) in
+files is not protected.
+
+fscrypt is not guaranteed to protect confidentiality or authenticity
+if an attacker is able to manipulate the filesystem offline prior to
+an authorized user later accessing the filesystem.
+
+For the Lustre case, block devices are Lustre targets attached to
+the Lustre servers. Manipulating the filesystem offline means
+accessing the filesystem on these targets while Lustre is offline.
+
+Online attacks
+--------------
+
+fscrypt (and storage encryption in general) can only provide limited
+protection, if any at all, against online attacks.  In detail:
+
+Side-channel attacks
+~~~~~~~~~~~~~~~~~~~~
+
+fscrypt is only resistant to side-channel attacks, such as timing or
+electromagnetic attacks, to the extent that the underlying Linux
+Cryptographic API algorithms are.  If a vulnerable algorithm is used,
+such as a table-based implementation of AES, it may be possible for an
+attacker to mount a side channel attack against the online system.
+Side channel attacks may also be mounted against applications
+consuming decrypted data.
+
+Unauthorized file access on Lustre client
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+
+After an encryption key has been added, fscrypt does not hide the
+plaintext file contents or filenames from other users on the same
+system.  Instead, existing access control mechanisms such as file mode
+bits, POSIX ACLs, LSMs, or namespaces should be used for this purpose.
+
+(For the reasoning behind this, understand that while the key is
+added, the confidentiality of the data, from the perspective of the
+system itself, is *not* protected by the mathematical properties of
+encryption but rather only by the correctness of the kernel.
+Therefore, any encryption-specific access control checks would merely
+be enforced by kernel *code* and therefore would be largely redundant
+with the wide variety of access control mechanisms already available.)
+
+For the Lustre case, it means plaintext file contents or filenames are
+not hidden from other users on the same Lustre client.
+
+Lustre client kernel memory compromise
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+
+An attacker who compromises the system enough to read from arbitrary
+memory, e.g. by mounting a physical attack or by exploiting a kernel
+security vulnerability, can compromise all encryption keys that are
+currently in use.
+
+However, fscrypt with v2 encryption policies allows encryption keys to
+be removed from the kernel, which may protect them from later
+compromise. Key removal can be carried out by non-root users.
+
+In more detail, the FS_IOC_REMOVE_ENCRYPTION_KEY ioctl will wipe a
+master encryption key from kernel memory.  Moreover, it will try to
+evict all cached inodes which had been "unlocked" using the key,
+thereby wiping their per-file keys and making them once again appear
+"locked", i.e. in ciphertext or encrypted form.
+
+However, FS_IOC_REMOVE_ENCRYPTION_KEY has some limitations:
+
+- Per-file keys for in-use files will *not* be removed or wiped.
+  Therefore, for maximum effect, userspace should close the relevant
+  encrypted files and directories before removing a master key, as
+  well as kill any processes whose working directory is in an affected
+  encrypted directory.
+
+- The kernel cannot magically wipe copies of the master key(s) that
+  userspace might have as well.  Therefore, userspace must wipe all
+  copies of the master key(s) it makes as well.  Naturally, the same
+  also applies to all higher levels in the key hierarchy.  Userspace
+  should also follow other security precautions such as mlock()ing
+  memory containing keys to prevent it from being swapped out.
+
+- In general, decrypted contents and filenames in the kernel VFS
+  caches are freed but not wiped.  Therefore, portions thereof may be
+  recoverable from freed memory, even after the corresponding key(s)
+  were wiped.  To partially solve this, you can set
+  CONFIG_PAGE_POISONING=y in your kernel config and add page_poison=1
+  to your kernel command line.  However, this has a performance cost.
+
+- Secret keys might still exist in CPU registers, in crypto
+  accelerator hardware (if used by the crypto API to implement any of
+  the algorithms), or in other places not explicitly considered here.
+
+Lustre server kernel memory compromise
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+
+An attacker on a Lustre server who compromises the system enough to
+read from arbitrary memory, e.g. by mounting a physical attack or by
+exploiting a kernel security vulnerability, cannot compromise Lustre
+files content. Indeed, encryption keys are not forwarded to the Lustre
+servers, and servers do not carry out decryption or encryption.
+Moreover, RPCs received by servers contain encrypted data, which is
+put as is in blocks to be stored on disk.
+
+Per-file key compromise
+~~~~~~~~~~~~~~~~~~~~~~~
+
+With one exception, fscrypt never uses the master key(s) for
+encryption directly.  Instead, they are only used as input to a KDF
+(Key Derivation Function) to derive the actual keys.
+
+For v2 encryption policies, the KDF is HKDF-SHA512. The master key is
+passed as the "input keying material", no salt is used, and a distinct
+"application-specific information string" is used for each distinct
+key to be derived.  For example, when a per-file encryption key is
+derived, the application-specific information string is the file's
+nonce prefixed with "fscrypt\0" and a context byte.  Different context
+bytes are used for other types of derived keys.
+
+So the per-file keys used to encrypt each file individually are
+obtained from a HKDF-SHA512 mechanism that is flexible, nonreversible,
+and evenly distributes entropy from the master key.
+HKDF is also standardized and widely used by other software.
+
+As a consequence, a compromise of a per-file key only impacts the
+associated file, not the master key.
+
+Master key verification
+~~~~~~~~~~~~~~~~~~~~~~~
+
+For master keys used for v2 encryption policies, a unique 16-byte "key
+identifier" is derived using the KDF.  This value is stored in
+the clear, and is used to reliably identify the key itself.
+
+Consequently, no malicious user can associate the wrong key with
+encrypted files.
-- 
1.8.3.1
