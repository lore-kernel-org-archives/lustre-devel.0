From: Peter J Braam <Peter.Braam@Sun.COM>
Date: Wed, 23 Jan 2008 09:01:09 +0800
Subject: [Lustre-devel] [Fwd: flash cache page]
Message-ID: <479691D5.6040009@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



-------- Original Message --------
Subject: 	flash cache page
Date: 	Wed, 23 Jan 2008 08:46:43 +0800
From: 	Peter J Braam <Peter.Braam@Sun.COM>
To: 	Vladimir V. Saveliev <Vladimir.Saveliev@Sun.COM>, 
lustre-devel at lustre.org
References: 	<478E29FF.2050306@sun.com> <478E52AE.4060801@sun.com> 
<1200609618.30173.3.camel@linux.site>



<div class="moz-text-flowed" style="font-family: -moz-fixed">Vladimir -

Here are some suggestions to improve the requirements & architecture for 
the flash cache.


1 Use case table.

i. we decided on an implementation constraint to store both file layouts 
as attributes of objects in a redirection layer in the client.  These 
layouts would be obtained from the MDS cluster, see (iv)

ii. We decided that locks would be taken in a hierarchical  manner -  
the flash cache would run a LDLM and locks would be taken there.

iii. Correctness would be handled automatically through the 
hierarchy.    However, to avoid a lot of reading "write only locks" used 
when entire pages are written are probably desirable (i.e. the caching 
infrastructure on the flash OST's is different from a Lustre client).

iv How EA2 is acquired needs more detail.


v Power loss needs a discussion - after restarting the cache an iterator 
is needed to push the data out.

2. QAS scenarios - these do need to be written.  These sketchy notes are 
not getting us much further.

3. Implementation details (many are not)

i.  What was the specific use of the "whole file" bit for MDT locks? We 
had several uses that showed its value - we should write them down 
before we forget.

ii. Please change all of these into detailed well written sentences - 
most are quality attribute scenarios and should be documented with a 
small table for each.

Peter
</div>
