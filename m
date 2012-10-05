From: Oleg Drokin <green@whamcloud.com>
Date: Thu, 4 Oct 2012 23:04:43 -0400
Subject: [Lustre-devel] merges to b2_<x>
In-Reply-To: <50209FD0.8000306@cray.com>
References: <50209FD0.8000306@cray.com>
Message-ID: <7FD7400E-1AA0-48C2-B844-879EBC85933A@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Aug 7, 2012, at 12:55 AM, Cory Spitz wrote:
> We at Cray have been looking at b2_1 landings, and one thing that I 
> think would be nice is if we could identify the master commit that the 
> b2_1 commit is based on directly from the mod header.  Unless, of 
> course, there is an easy way to derive this information via git.  I hope 

I imagine you can look at change id and look for the same id in the master landings?
Perhaps you can even automate that.

Bye,
    Oleg
--
Oleg Drokin
Senior Software Engineer
Whamcloud, Inc.
