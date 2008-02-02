From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Sat, 02 Feb 2008 01:26:35 -0500
Subject: [Lustre-devel] Reducing amount of glimpses
Message-ID: <A1C83110-58BF-43A2-88F3-68C6C53BFB6C@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

    Doing some large scale testing at ORNL, interesting pattern came up.
    Suppose we are doing large-scale IOR testing on a shared file.
    Some unlucky client does its writing at highest offset (or, at the  
beginning,
    was unlucky enough to grab whole-object PW lock).
    As other clients do their writes, they would do glimpses first to  
find out file
    size. Now those glimpses turn into thousands of glimpse requests  
to that poor
    client. And many of them actually coming in parallel.
    So I was thinking - perhaps it would be nice for a  
filter_intent_policy() to check
    if there are any glimpse requests being in flight to that client  
already for that
    same lock, and if there are, just wait for the request to return  
and use data from
    there?
    Of course potential caveat here is that we have no way to tell if  
the request reached
    client by the time we started our processing or not, and so  
potentially we might get
    size data that is a bit stale, but I wonder if this is critical  
enough in our case?

    Any ideas?

Bye,
     Oleg
