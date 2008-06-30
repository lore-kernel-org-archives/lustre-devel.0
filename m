From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Mon, 30 Jun 2008 14:11:05 +0400
Subject: [Lustre-devel] some thoughts on COS
In-Reply-To: <486894E9.1030104@sun.com>
References: <C46FF0A8.591A%peter.braam@sun.com> <486894E9.1030104@sun.com>
Message-ID: <18536.45369.176085.583659@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Alex Zhuravlev writes:
 > Hi,
 > 
 > all access to an object can be broken into 3 phases:
 > 1) lock is acquired and used to modify data, no concurrent
 >     access as data is inconsistent
 > 2) data is consistent, but uncommitted; thus same client can
 >     access data, others can not

Other clients cannot read uncommitted data, but they can safely
overwrite them. Do we care about such use cases?

 > 3) all clients can access data

Nikita.
