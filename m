From: Johann Lombardi <johann.lombardi@oracle.com>
Date: Thu, 9 Dec 2010 17:50:30 +0100
Subject: [Lustre-devel] Git commit message format
In-Reply-To: <9E373505737CCD46890A96FA1877E8DA01D9824E@XY01EX22.xy01.xyratex.com>
References: <9E373505737CCD46890A96FA1877E8DA01D9824E@XY01EX22.xy01.xyratex.com>
Message-ID: <20101209165030.GA2370@granier.hd.free.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Dec 09, 2010 at 11:07:46AM +0000, Nikitas Angelinas wrote:
> The 'Submitting Patches' page in the wiki
> http://wiki.lustre.org/index.php/Submitting_Patches describes the commit
> message format to be used. It states that 'i=<inspector name>' should be
> used to denote the patch inspectors; while this is used in the majority
> of commits, some make use of an 'a=' (e.g. commit
> 0fda09a56aaf8105c7c5cb0326d0c8fcec6fc04c),

This stands for "author". This is used when the author of the patch is different from the person who submits it. While this was needed for CVS, we can now easily change the "Author" field with git and land a patch on behalf of someone else.

> 'r=' (e.g. same commit 0fda09a56aaf8105c7c5cb0326d0c8fcec6fc04c),

I think this is used for "reviewer". However, this is not compliant with our rules and "i" should be used instead.

> or 'o=' (e.g. commit 80da07e3994946f85cc14f32888ed0c8ffd5d39e).

This is the same as "a" and it stands for "original author".

Johann
