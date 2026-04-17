.slider-container {
position: relative;
width: 100%;
height: 500px;
overflow: hidden;
margin-bottom: 30px;
background-color: #f0f0f0;
}

.slide {
position: absolute;
top: 0;
left: 0;
width: 100%;
height: 100%;
background-size: cover;
background-position: center;
opacity: 0;
transition: opacity 0.8s ease-in-out;
display: flex;
align-items: center;
justify-content: center;
text-align: center;
}

.slide.active {
opacity: 1;
z-index: 1;
}

.slide::before {
display: none;
}

.promo-hero__overlay {
position: absolute;
bottom: 40px;
left: 50%;
transform: translateX(-50%);
width: 100%;
text-align: center;
padding: 0;
z-index: 5;
}

.promo-hero__overlay h1 {
display: none;
}

.promo-hero__overlay p {
display: none;
}

.slide.active .promo-hero__overlay h1,
.slide.active .promo-hero__overlay p {
display: none;
}


.btn-hero {
display: inline-block;
padding: 12px 40px;
background-color: #fff;
color: #2c5c38;
text-decoration: none;
font-weight: 800;
font-size: 1.1rem;
border-radius: 50px;
box-shadow: 0 4px 15px rgba(0,0,0,0.3);
transition: all 0.3s ease;
text-transform: uppercase;

opacity: 1;
transform: none;
}
.btn-hero:hover {
background-color: #4CAF50;
color: #fff;
transform: translateY(-3px);
}
.slide.active .btn-hero {
opacity: 1;
transform: translateY(0);
}

.btn-hero:hover {
background-color: transparent;
color: #fff;
}


.slider-btn {
position: absolute;
top: 50%;
transform: translateY(-50%);
background: rgba(255, 255, 255, 0.2);
border: 1px solid rgba(255,255,255,0.5);
color: white;
font-size: 1.5rem;
width: 50px;
height: 50px;
border-radius: 50%;
cursor: pointer;
z-index: 10;
transition: all 0.3s;
display: flex;
align-items: center;
justify-content: center;
}

.slider-btn:hover {
background: rgba(255, 255, 255, 1);
color: #333;
}

.slider-prev { left: 30px; }
.slider-next { right: 30px; }

.slider-dots {
position: absolute;
bottom: 25px;
left: 50%;
transform: translateX(-50%);
display: flex;
gap: 12px;
z-index: 10;
}

.dot {
width: 12px;
height: 12px;
background: rgba(255, 255, 255, 0.5);
border-radius: 50%;
cursor: pointer;
transition: all 0.3s;
border: 1px solid transparent;
}

.dot.active {
background: #fff;
transform: scale(1.3);
border-color: #4CAF50;
}


.campaign-section {
padding: 40px 0;
border-bottom: 1px solid #eee;
}

.campaign-header {
display: flex;
justify-content: space-between;
align-items: flex-end;
margin-bottom: 25px;
border-bottom: 2px solid #4CAF50;
padding-bottom: 10px;
}

.campaign-header__left h2 {
font-size: 1.8rem;
color: #2c3e50;
margin-bottom: 5px;
font-weight: 700;
}

.campaign-timer {
display: inline-block;
background-color: #e74c3c;
color: #fff;
padding: 5px 15px;
border-radius: 20px;
font-size: 0.9rem;
font-weight: 500;
margin-top: 5px;
}

.campaign-timer i { margin-right: 5px; }

.btn-view-all {
text-decoration: none;
color: #4CAF50;
font-weight: 600;
font-size: 1rem;
transition: all 0.3s ease;
}

.btn-view-all:hover {
color: #2e7d32;
transform: translateX(5px);
}


@media (max-width: 768px) {
.slider-container { height: 300px; }
.promo-hero__overlay h1 { font-size: 1.8rem; }
.promo-hero__overlay p { font-size: 1rem; display: none; }
.campaign-header { flex-direction: column; align-items: flex-start; gap: 10px; }
}