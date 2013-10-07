From: Tobias Groschup <groschup@stud.uni-heidelberg.de>
Date: Mon, 07 Oct 2013 16:42:48 +0200
Subject: [Lustre-devel] Starting and using  a self written LND
Message-ID: <5252C868.2050104@stud.uni-heidelberg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi all,

I am still at the task of writing a new LND. Finally got Lustre to build 
with our own software stack.

Now I want to test the new LND. Of course, it does not implement much 
functionality yet. In fact, it only has a stump for the send and receive 
functions, and a startup and shutdown function which sets up the 
software context for the network card and closes it.
I can load the module, and LNet does not crash after adding the new 
entries to the LND types enum in libcfs/include/libcfs/libcfs private.h 
and to libcfs_netstrfns[] in libcfs/libcfs/nidstrings.c.

So the question is: how does one invoke the startup function after 
loading an LND module? I tried lclt and its network up command, which 
returned without error, but I did not see the debug output which is 
printed via printks.

And: are the modifications to the libcfs mentioned above all that are 
needed to declare an LND to libcfs?

Thanks and Greetings
Tobias
