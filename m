From: Chris Horn <hornc@cray.com>
Date: Tue, 15 Oct 2013 20:03:33 -0000
Subject: [Lustre-devel] Starting and using  a self written LND
In-Reply-To: <5252C868.2050104@stud.uni-heidelberg.de>
References: <5252C868.2050104@stud.uni-heidelberg.de>
Message-ID: <CD2D33E7-4FB2-4D37-942F-06C18ACDE3CB@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

LNET only calls LND startup functions for networks defined in the LNET module setting (modprobe.conf.local or equivalent). See lnet_startup_lndnis() and lnet_parse_networks().

Chris Horn

On Oct 7, 2013, at 9:42 AM, Tobias Groschup <groschup@stud.uni-heidelberg.de> wrote:

> Hi all,
> 
> I am still at the task of writing a new LND. Finally got Lustre to build 
> with our own software stack.
> 
> Now I want to test the new LND. Of course, it does not implement much 
> functionality yet. In fact, it only has a stump for the send and receive 
> functions, and a startup and shutdown function which sets up the 
> software context for the network card and closes it.
> I can load the module, and LNet does not crash after adding the new 
> entries to the LND types enum in libcfs/include/libcfs/libcfs private.h 
> and to libcfs_netstrfns[] in libcfs/libcfs/nidstrings.c.
> 
> So the question is: how does one invoke the startup function after 
> loading an LND module? I tried lclt and its network up command, which 
> returned without error, but I did not see the debug output which is 
> printed via printks.
> 
> And: are the modifications to the libcfs mentioned above all that are 
> needed to declare an LND to libcfs?
> 
> Thanks and Greetings
> Tobias
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
