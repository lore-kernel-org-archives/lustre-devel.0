From: Yuriy Umanets <Yury.Umanets@Sun.COM>
Date: Mon, 18 Feb 2008 23:57:04 +0200
Subject: [Lustre-devel] Global generic database
In-Reply-To: <47B335B6.5010703@sun.com>
References: <47B335B6.5010703@sun.com>
Message-ID: <47B9FF30.6040409@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathaniel Rutman wrote:
> The design of various new features in Lustre call for global (filesystem 
> wide) databases, accessible from
> clients or other servers:
> A. pools - pool descriptions (pool #1 = OSTs 1-10,30-60), pool policies 
> (all .jpg files to pool #1)
> B. filesets - fileset policies (log creates on fileset #1 to feed "foo")
> C. HSM - (aureleien - what was the use case here?)
>
> We've already implemented at least 2 of these:
> D. Fid Location Database - (is this done?)
>   
This is basic service in new MDS stack. Though its implementation lacks 
DHT support as it was designed originally. Currently it uses round-robin 
as a policy for spreading parts of FLD over MDS nodes in a cluster. 
Another issue is that, originally intention was to make whole Lustre FLD 
aware but now only MDS nodes store parts of FLD as only MDS uses new fids.

Thanks.

-- 
umka
