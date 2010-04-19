From: Oleg Drokin <oleg.drokin@oracle.com>
Date: Mon, 19 Apr 2010 18:31:49 -0400
Subject: [Lustre-devel] Flush on file close
In-Reply-To: <201004192230.48196.andrew.perepechko@sun.com>
References: <201004192230.48196.andrew.perepechko@sun.com>
Message-ID: <AD12F5A3-D702-40CC-818F-CC477E3E90B1@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Apr 19, 2010, at 2:30 PM, Andrew Perepechko wrote:
> Since syncing may degrade performance to a large extent, what do you think is 
> the best/most convenient/least intrusive way to switch to that behaviour? 
> Should it be a mount option for the client or anything else?

Personally I think this is a non-issue for us.
There is no mad dash in other filesystems to implement this, aside from NFS where this
is what is guaranteed.
As long as we don't lose data after close (which we usually don't anyway) we are in the clear.
If we do (eviction, double failure) then there was some system exception that is kind of
similar to disk failure for regular fs.
Apps doing this "close after each write" should be fixed anyway because now they incur
additional overhead of two extra unneeded sync RPCs (open + close) and adding more overhead
to this is not going to help even if made optional.

Bye,
    Oleg
