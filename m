From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 26 Nov 2015 20:02:21 +0100
Subject: [lustre-devel] [PATCH 3/3] staging: lustre: Less function calls
 in class_register_type() after error detection
In-Reply-To: <20151126165331.GA7882@kroah.com>
References: <alpine.DEB.2.10.1402251840450.7035@hadrien>
	<530CF8FF.8080600@users.sourceforge.net>
	<alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
	<530DD06F.4090703@users.sourceforge.net>
	<alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<563B473C.5090508@users.sourceforge.net>
	<563B4991.90005@users.sourceforge.net>
	<20151125163901.GA7368@kroah.com>
	<5656AFEC.8030709@users.sourceforge.net>
	<20151126165331.GA7882@kroah.com>
Message-ID: <5657573D.4080905@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>> Do you try this update suggestion out without integrating the corresponding previous
>> update suggestion "Delete unnecessary checks before two function calls"
>> where I proposed to remove extra checks before a few calls of the function "kobject_put"
>> (which seems to matter for the patch hunk in the shown error message)?
>> https://lkml.org/lkml/2015/11/5/276
>> https://www.mail-archive.com/linux-kernel at vger.kernel.org/msg1013635.html
> 
> I guess so, I don't remember, I don't see any patches from you earlier
> in my "todo" mbox.

I am still waiting for further constructive feedback on a bunch
of my update suggestions which are derived from static source code analysis.

It can be the usual challenge to get a bit more attention for them.
Other software improvements will result in bigger effects than the source code
fine-tuning I propose, won't it?

I would like to acknowledge that changes like the following from this patch series
can still be applied together for the software "Linux next-20151126".
* 0001-staging-lustre-Delete-unnecessary-checks-before-two.patch
* 0003-staging-lustre-Less-function-calls-in-class_register.patch


>> Would you like to reject the first update step from this patch series
>> so that I need to adapt my approach to your software design decision?
> 
> I have no idea what you are talking about.  I have no recolection of
> previous patches or conversations about your patches.

* Dan Carpenter expressed his software design concerns around hidden sanity checks
  a few times.
  How do you think about to give the proposed changes another chance?

* Positive feedback is occasionally increasing by specific subsystem supporters
  and maintainers.
  How will our collaboration evolve further?


Do you want that I resend any mails/patches from my "waiting queue"?

Regards,
Markus
