From: James Simmons <jsimmons@infradead.org>
Date: Fri, 30 Mar 2018 20:12:09 +0100 (BST)
Subject: [lustre-devel] lustre and loopback device
In-Reply-To: <87d0zr668j.fsf@notabene.neil.brown.name>
References: <alpine.LFD.2.21.1803222322450.17346@casper.infradead.org>
 <87d0zr668j.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1803302011110.9681@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Fri, Mar 23 2018, James Simmons wrote:
> 
> > Hi Neil
> >
> >       So once long ago lustre had its own loopback device due to the 
> > upstream loopback device not supporting Direct I/O. Once it did we
> > dropped support for our custom driver. Recently their has been interest
> > in using the loopback driver and Jinshan discussed with me about reviving
> > our custom driver which I'm not thrilled about. He was seeing problems
> > with Direct I/O above 64K. Do you know the details why that limitation
> > exist. Perhaps it can be resolved or maybe we are missing something?
> > Thanks for your help.
> 
> Hi James, and Jinshan,
>  What sort of problems do you see with 64K DIO requests?
>  Is it a throughput problem or are you seeing IO errors?
>  Would it be easy to demonstrate the problem in a cluster
>  comprising a few VMs, or is real hardware needed?  If VMs are OK,
>  can you tell me exactly how to duplicate the problem?
> 
>  If loop gets a multi-bio request, it will allocate a bvec array
>  to hold all the bio_vecs.  If there are more than 256 pages (1Meg)
>  in a request, this could easily fail. 5 consecutive 64K requests on a
>  machine without much free memory could hit problems here.
>  If that is the problem, it should be easy to fix (request the number
>  given to blk_queue_max_hw_sectors).

Jinshan can you post a reproducer so we can see the problem.  
