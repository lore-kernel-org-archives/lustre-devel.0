From: Wendy Cheng <s.wendy.cheng@gmail.com>
Date: Fri, 11 Oct 2013 10:59:41 -0700
Subject: [Lustre-devel] Kernel crash from "mkfs.lustre --index" setting
In-Reply-To: <CE7D8557.721A%cliff.white@intel.com>
References: <CABgxfbG2DWP-Md7SjQnhEkSUcqaBFqkyGMc0f=t=cVsPHu80sg@mail.gmail.com>
	<CE7D8557.721A%cliff.white@intel.com>
Message-ID: <CABgxfbE1LruxE8Uc-Vb_JnEyRnJcC8FUa0Q-kPjNNgT6zR7oCg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Oct 11, 2013 at 10:41 AM, White, Cliff <cliff.white@intel.com> wrote:

> 1.
> --index is used to enumerate OSTs and MDT, when using DNE.
> The index MUST be unique, and indexes must not have gaps.

I see ... index must not have gaps. However, a user error could crash
the kernelr . Does that sound right ? .

>
> 3. Surprise you how?
>
> HPDD-discuss is likely a better list for these sorts of questions,
> lustre-devel is for code development.

Thanks .. I'll move the discuss there sometime next week. It looks to
me Lustre is doing sync to the disks all the time vs. other network
filesystem (e.g. NFS) that does caching quite aggressively.

-- Wendy
