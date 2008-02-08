From: Peter J Braam <Peter.Braam@Sun.COM>
Date: Fri, 08 Feb 2008 13:37:48 -0700
Subject: [Lustre-devel] [RFC] parallel enqueue
In-Reply-To: <47AC75E3.7010901@sun.com>
References: <47AC75E3.7010901@sun.com>
Message-ID: <47ACBD9C.3060402@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yes this is a good idea, but probably not extremely urgent.

- Peter -

Alex Zhuravlev wrote:
> Hi,
>
> in some cases (truncate, append) we still use serialized enqueue
> when all locks have to be enqueued synchronously one by one.
>
> what if we could mark all locks issued by single client with some
> unique tag (timestamp + nid?), then enqueue them all and then, in
> case of conflict, in blocking ast handler compare tag of conflicting
> lock with own tag, cancel our granted locks if our tag is greater
> than tag of conflicting lock and enqueue them again?
>
> thanks, Alex
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
