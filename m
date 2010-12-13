From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Sun, 12 Dec 2010 19:28:06 -0700
Subject: [Lustre-devel] [Lustre-discuss] Optimal block size for database
	...
In-Reply-To: <AANLkTikzOQ6Gy1g8UXTN_99hee2zv4PuzXAL3=Nynqye@mail.gmail.com>
References: <AANLkTikzOQ6Gy1g8UXTN_99hee2zv4PuzXAL3=Nynqye@mail.gmail.com>
Message-ID: <C287EBED-7748-4EDE-A8E4-E88348E760DC@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre only supports 4096-byte blocksize for ldiskfs, so that makes your study very easy. I suspect that Oracle database uses 8192-byte blocks, but to be honest I don't know anything about it. 

That said, Lustre is probably not very well suited for Oracle databases, but I'd be very happy to see any results you can generate in this configuration. Please post the results to this list. 

Cheers, Andreas

On 2010-12-11, at 19:36, Onkar Mahajan <kern.devel@gmail.com> wrote:

> Hi All, 
>        I am studying Lustre file system for optimal block size 
> for ldiskfs so as to get best performance out of Oracle database. 
>        What is the average size of files that Oracle database 
> access ?
> 
> Regards,
> Onkar
> _______________________________________________
> Lustre-discuss mailing list
> Lustre-discuss at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-discuss
