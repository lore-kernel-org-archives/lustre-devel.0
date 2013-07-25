From: Michael Kluge <michael.kluge@tu-dresden.de>
Date: Thu, 25 Jul 2013 07:13:19 +0200
Subject: [Lustre-devel] mounting a device twice
In-Reply-To: <AB42A35A-B204-4A5C-BB9E-5471BA85BACC@intel.com>
References: <51F00E38.7060601@tu-dresden.de>
	<AB42A35A-B204-4A5C-BB9E-5471BA85BACC@intel.com>
Message-ID: <51F0B3EF.8000205@tu-dresden.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Andreas,

thanks for the information.


Michael

On 25.07.2013 04:39, Dilger, Andreas wrote:
> You can do this because the kernel is not actually mounting the block device twice. Lustre is mounting the block device internally as type ldiskfs and the second mount will be like a bind mount of the same filesystem root tree.
>
> I do this on my local filesystem for quick debugging, but it isn't strictly safe on an active filesystem because modifications can render the Lustre and on disk state inconsistent.
>
> Cheers, Andreas
>
> On 2013-07-24, at 11:27, "Michael Kluge" <michael.kluge@tu-dresden.de> wrote:
>
>> Hi list,
>>
>> can I mount a device mounted as lustre a second time as ldiskfs or would MMP protect me from doing this?
>>
>>
>> Regards, Michael

-------------- next part --------------
A non-text attachment was scrubbed...
Name: smime.p7s
Type: application/pkcs7-signature
Size: 4859 bytes
Desc: S/MIME Cryptographic Signature
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20130725/4f5e9b56/attachment.bin>
