document.addEventListener('DOMContentLoaded', () => {
    const sections = document.querySelectorAll('.accordion-button');
    sections.forEach((button) => {
        button.addEventListener('click', () => {
            button.scrollIntoView({ behavior: 'smooth', block: 'center' });
        });
    });
});

document.addEventListener('scroll', () => {
    const bodyElement = document.body;
    const scrollPosition = window.scrollY;
    bodyElement.style.backgroundPositionY = `${scrollPosition * 0.5}px`;
});
