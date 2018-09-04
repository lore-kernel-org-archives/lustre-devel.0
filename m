From: James Simmons <jsimmons@infradead.org>
Date: Tue, 4 Sep 2018 19:35:10 +0100 (BST)
Subject: [lustre-devel] fixing last lctl set_param -P problem
Message-ID: <alpine.LFD.2.21.1809041836100.7402@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


I originally posted this in the LU-7004 jira ticket :

https://jira.whamcloud.com/browse/LU-7004

but no one has replied so I thought it would be good to post here.

So this is last regression with lctl set_param -P. Some test use the form 
get the parameter value:

lctl set_param osc.lustre-OST0001-osc-[^M]*.active=1

The shell seems to expand this properly or the get_param routine parses 
this correctly.

Now if I run on the MGS lctl set_param -P osc.lustre-OST0001-osc[^M]*.active=1
then the [^M] is actually cached in the config logs. The function 
obdname2fsname() chokes on this wildcard. So the question is how to handle this.
I see the following option:

1) Make the shell expand the [^M] to some value before passing the string 
   to lctl itself. Have to look at this.

2) Use regex or something in the C code of lctl to expand this out before 
   packing the data for the ioctl on the MGS.

3) Change the test scripts to drop the [^M] for lctl set_param -P.

Which is the best option?
