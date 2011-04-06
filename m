From: Alex Zhuravlev <bzzz@whamcloud.com>
Date: Wed, 6 Apr 2011 21:33:16 +0400
Subject: [Lustre-devel] llog API, locking and concurrency
In-Reply-To: <4D9C9BC7.5050603@cea.fr>
References: <4D9C9BC7.5050603@cea.fr>
Message-ID: <BANLkTikOwb3hObm9jvjP50gKEs_gHJ3BQQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

correct, llog is doing serialization internally.

thanks, Alex

On Wed, Apr 6, 2011 at 8:58 PM, DEGREMONT Aurelien <
aurelien.degremont@cea.fr> wrote:

> Hello
>
> I'm wondering what is the correct way to use llog_ API regarding locking
> and concurrencies?
>
> When looking at code, it seems llog already deal with proper locking
> when several thread access the same llog.
> The codes that use this king of log do not seem to add more locking when
> using it.
>
> Is this correct? llog_* call can be called without taking care of
> concurrency?
>
>
> Thanks
>
> Aur?lien
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110406/1da732b7/attachment.htm>
