From: White, Cliff <cliff.white@intel.com>
Date: Fri, 11 Oct 2013 17:41:33 +0000
Subject: [Lustre-devel] Kernel crash from "mkfs.lustre --index" setting
In-Reply-To: <CABgxfbG2DWP-Md7SjQnhEkSUcqaBFqkyGMc0f=t=cVsPHu80sg@mail.gmail.com>
Message-ID: <CE7D8557.721A%cliff.white@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 10/11/13 10:11 AM, "Wendy Cheng" <s.wendy.cheng@gmail.com> wrote:

>This panic seems to be generic regardless the platform, though I'm
>actually on Intel Xeon Phi Lustre (client) nodes.
>
>New to Lustre, I mistakenly thought the "index" option of mkfs.lustre
>was for software raid so I formatted one of the server disks as the
>following:
>
>server> mkfs.lustre --reformat --fsname=lus1 --mgs --mdt --index=1
>/dev/sdd1
>server> mkfs.lustre --reformat --ost --fsname=lus1
>--mgsnode=192.168.20.46 at o2ib0 --index=1 /dev/sde1
>
>The client mount immediately crashed at lmv_get_info(). The attached
>patch fixed that particular panic ... but unfortunately crashed at an
>assertion further down the path. I'll be travelling next week so might
>give up pursuing this issue. The disks are now subsequently
>re-formatted with index=0 - things seem to work fine and performance
>numbers collected. Three questions here:
>
>1. What is this "index" option all about ?
>2. Does the problem worth being fixed ? Or is it a user error ?
>3. The performance numbers (again, NOT Xeon Phi specific) surprise me.
>Would this list be a good place to ask questions ?
>
>-- Wendy
>
1.
--index is used to enumerate OSTs and MDT, when using DNE.
The index MUST be unique, and indexes must not have gaps.
So, you should do this:
server> mkfs.lustre --reformat --fsname=lus1 --mgs --mdt --index=0
/dev/sdd1 /* First MDT */
server> mkfs.lustre --reformat --ost --fsname=lus1
--mgsnode=192.168.20.46 at o2ib0 --index=0 /dev/sde1 /* first OST */
If you add a second OST partition:

server> mkfs.lustre --reformat --ost --fsname=lus1
--mgsnode=192.168.20.46 at o2ib0 --index=1 /dev/sdfoo /* second OST */

And a third:
server> mkfs.lustre --reformat --ost --fsname=lus1
--mgsnode=192.168.20.46 at o2ib0 --index=2 /dev/sdbar /* third OST */


2.- You must fix this, or things won't work. I would suggest starting
again, and doing a reformat
Etc,etc

3. Surprise you how?

HPDD-discuss is likely a better list for these sorts of questions,
lustre-devel is for code development.
Cliffw
