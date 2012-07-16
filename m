From: Nathan Rutman <nrutman@gmail.com>
Date: Mon, 16 Jul 2012 11:02:32 -0700
Subject: [Lustre-devel] Lustre coding style: use tabs for indentation
In-Reply-To: <C28123A9-C33A-4C45-9DAC-0036A528A600@whamcloud.com>
References: <C28123A9-C33A-4C45-9DAC-0036A528A600@whamcloud.com>
Message-ID: <055F1C75-208D-4DBF-A240-F4B9DC988CD6@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Andreas - should we be removing the vim/emacs modelines from source files as we generate patches?


On May 8, 2012, at 1:17 PM, Andreas Dilger wrote:

> NOTE TO ALL LUSTRE DEVELOPERS
> =============================
> 
> As previously discussed at LUG in Austin, and in these lists, we've decided to change Lustre to use the upstream Linux kernel coding style.  This is being done in order to allow merging the Lustre client code into the upstream kernel.
> 
> In most cases, the two coding styles agree, but one of the major differences is that Lustre uses 8-space indents, while the kernel uses tabs.  To ensure the transition is not disruptive to ongoing work in patches and branches, there will NOT be an en-masse change of every line of Lustre to use tabs.  This would cause 280kLOC of changes in a short time, and would break landing of all in-flight patches and branches, and the commit history of every line of code would be useless.
> 
> 
> Instead, there will be an incremental change to the coding style:
> * All lines of code that are modified or added by new or updated
>  patches must use tabs for indentation.  This includes tests.
> * If there are fewer than 6 unmodified lines between two modified
>  lines (i.e. normal "diff" context) still using spaces, they should
>  also be converted to using tabs.
> * If there are only a "handful" of lines remaining in a function,
>  test, structure, header, etc. that are using spaces for indentation,
>  they should also be converted to using tabs (including the function
>  declaration, if needed).  Use your judgement, but since every line
>  must be changed at some point, it is better to err on the side of
>  converting more lines to tabs than fewer.
> 
> By modifying adjacent lines together, and stragglers in a file, it will not significantly increase the size or number of the patches, and it will avoid messy blocks of code that have both tabs and spaces interleaved.  If there are other whitespace or code style issues (e.g. trailing spaces or tabs, placement of braces or operators, etc.) on lines being modified, it would be useful to clean them up at the same time, to also improve the overall quality of the code.
> 
> Note that in Gerrit it is possible to permanently select "Ignore Whitespace" as "All" when reviewing a patch, so that the indentation change doesn't interfere with the understanding of the patch.
> 
> The build/checkpatch.pl script has already been updated to match the latest kernel version, and requires tabs for indentation.  The vim/emacs modelines that force spaces for indentation have also been removed.
> 
> Given the number of lines of code that will be changing over the next year due to OSD restructuring, DNE, LNET, NRS, SMP scaling, etc., it is expected that a significant fraction of the lines will be converted by the 2.4 release.  By this time, we will evaluate whether an en-masse conversion of the remaining lines is warranted, whether for just the client code, or for all code.
> 
> Thanks for your cooperation in during this change.
> 
> Cheers, Andreas
> --
> Andreas Dilger                       Whamcloud, Inc.
> Principal Lustre Engineer            http://www.whamcloud.com/
> 
> 
> 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
