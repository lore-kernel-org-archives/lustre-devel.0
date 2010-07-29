From: Bernd Schubert <bs_lists@aakef.fastmail.fm>
Date: Thu, 29 Jul 2010 02:18:14 +0200
Subject: [Lustre-devel] dealloc in 1.8.4 and RHEL5.5
In-Reply-To: <201007290213.13288.bs_lists@aakef.fastmail.fm>
References: <201007290213.13288.bs_lists@aakef.fastmail.fm>
Message-ID: <201007290218.15076.bs_lists@aakef.fastmail.fm>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thursday, July 29, 2010, Bernd Schubert wrote:
> Hi all,
> 
> I see that dealloc is disabled in 1.8.4 by default also for RedHat kernels.
> I think it is a good idea to do that for RHEL 54 kernels, as I run into
> slight filesystem corruption on our test cluster, which I cannot explain
> except that the filesystem might have caused it. That was with 1.8.3 and
> ext4-ldiskfs with enabled dealloc.
> 
> Now my question is if dealloc really should be disabled for 1.8.4, as it
> will be based on RHEL 5.5 kernels. And as ext4 in 5.5 is based on 2.6.32,
> dealloc should work without much risk, shouldn't it? Or does it just need
> some testing? Unfortunately, I do not have a suitable reproducer for the
> issue above.

I think I see what is still missing - quota related dealloc patches have not 
been merged according to the 5.5 ext4 patch description.



-- 
Bernd Schubert
DataDirect Networks
