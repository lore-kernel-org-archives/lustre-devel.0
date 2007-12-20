From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 20 Dec 2007 13:52:28 -0700
Subject: [Lustre-devel] SNS and existing Lustre striping.
In-Reply-To: <200712202333.57536.alexander.zarochentsev@sun.com>
References: <200712202333.57536.alexander.zarochentsev@sun.com>
Message-ID: <476AD60C.1080803@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I was hoping for 1. to keep things simple.

- Peter -

Alexander Zarochentsev wrote:
> Hello,
>
> Coming SNS feature somehow duplicates and extents existing Lustre 
> striping functionality.  How will they (SNS and striping) coexist 
> in the future versions of Lustre?
>
> I see 3 possible variants:
>
> 1. SNS replaces striping everywhere.
> 2. one file can be SNS striped object or lustre striping object.
> 3. one file can be SNS on top of Lustre-striping or Lustre-striping on 
> SNS and, probably, one part of file can be SNS and another part is 
> Lustre-striped.
>
> Does #3 makes any sense?
>
> I would prefer to assume that correct answer is (2) -- there are SNS 
> files and Lustre-striped files, because Lustre-striped files probably 
> have less overhead.
>
> Thanks,
> Zam.
>   
