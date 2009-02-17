From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 17 Feb 2009 09:17:23 +0300
Subject: [Lustre-devel] Some investigations on  MDS creation rate
In-Reply-To: <CB88ADF9-B0C6-41FA-AFCE-F9CA1E2416BD@Sun.COM>
References: <DC147A4B-16CC-41B7-9C27-2F9BE64805FD@Sun.COM>
	<FE7ACA5E-C11C-41B7-BF1D-05F9A73C72DF@sun.com>
	<499985A7.7000600@sun.com>
	<CB88ADF9-B0C6-41FA-AFCE-F9CA1E2416BD@Sun.COM>
Message-ID: <499A5673.4060103@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Oleg Drokin wrote:
>> notice HEAD takes two ldlm locks for each create, 1.6 takes one.
> 
> What is the other one? I am looking at mdt_md_create and I see it locks 
> parent, but not child, just like b1_6.

one lock on whole parent directory (to invalidate client's cache), another
lock on part of parent directory with given hash. this is workaround for
slow creates from multiple clients due to rep-ack mechanism.

thanks, Alex
