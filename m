From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Wed, 13 Aug 2008 07:53:18 +0400
Subject: [Lustre-devel] Completion callbacks
In-Reply-To: <7B72F4D61F2D44C6ADCCF1BC952B9365@ebpc>
References: <7B72F4D61F2D44C6ADCCF1BC952B9365@ebpc>
Message-ID: <18594.23214.726184.960909@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton writes:
 > Hi,
 > 

[...]

 > 
 > I'd appreciate any feedback on these suggested changes.

What about starting with a single lock for callbacks, _different_ from
the lock protecting ME matching? Also, what callbacks lock protects
exactly? Maybe it can be replaced with a read-write lock?

Nikita.
