From: Jeremy Filizetti <jeremy.filizetti@gmail.com>
Date: Tue, 9 Nov 2010 10:55:28 -0500
Subject: [Lustre-devel] releasing BKL in lustre_fill_super
In-Reply-To: <AC0576E0-89E6-47C1-8739-ADD0B6C5D2AC@oracle.com>
References: <AANLkTinN5dP6KOqE3ZEo2ZKWxo_GJesAN5dvPFyVXc7c@mail.gmail.com>
	<53B6B788-B146-45B9-9FAB-F3F4C163B1B3@dilger.ca>
	<B0280D0B-7D61-48C0-99AD-CA45F5DD70A9@ddn.com>
	<AANLkTi=Ymq8NGgLnVx+rj0U-9nOqV0qeB7Lhumay7_Pk@mail.gmail.com>
	<AC0576E0-89E6-47C1-8739-ADD0B6C5D2AC@oracle.com>
Message-ID: <AANLkTinRSOxMDDMPMXuae6iE3DWX5wy5wzig5y25S-Q9@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>
>
> The first thing I always think about when seeing a problem like this is not
> "how to reduce this contention" but "do we need to be doing this at all"?


> Without having looked at that code in a long time, I'm having a hard time
> thinking why the OST needs to allocate a new block for the config during
> mount.  It is probably worthwhile to investigate why this is happening in
> the first place, and possibly just eliminating useless work, rather than
> making it slightly less slow.
>

 I can't really answer whether "we need to do it",  but I can elaborate on
what is happening.  The actual write that is being done during the
lustre_process_log is when the llog is being copied from the remote server
to the local server.  I assume this is at least a necessary step and no
getting rid of the llog without some sort of overhaul.  I don't really have
an idea on how large the llog can get but on the sizes I've seen it does
seem reasonable that it could be copied from the remote MGS into memory,
release the lock, and then write the log out to disk.


>
> Unfortunately, I don't have the bandwidth to look at this, but maybe Nathan
> or someone with more familiarity of the config code can chime in.
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101109/565348f6/attachment.htm>
